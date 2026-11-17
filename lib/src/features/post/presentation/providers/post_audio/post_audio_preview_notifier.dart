import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_player_data_source.dart';

import 'post_audio_preview_state.dart';

class PostAudioPreviewNotifier extends StateNotifier<PostAudioPreviewState> {
  PostAudioPreviewNotifier(this._player)
    : super(const PostAudioPreviewState.idle()) {
    _changes = _player.playbackChanges.listen(_onPlaybackChanged);
    _errors = _player.playbackErrors.listen((_) => _showFailure());
  }

  final PostAudioPlayerDataSource _player;
  late final StreamSubscription<({bool playing, bool completed})> _changes;
  late final StreamSubscription<void> _errors;
  String? _loadedPath;
  bool _acceptPlaybackEvents = false;
  bool _commandInProgress = false;
  int _playRequestId = 0;
  bool _backgroundStopPending = false;

  void stopForBackground() {
    if (!mounted || _backgroundStopPending || state is PostAudioPreviewIdle) {
      return;
    }

    _backgroundStopPending = true;
    _acceptPlaybackEvents = false;
    _playRequestId++; // 파일 로딩이 늦게 끝나도 재생하지 않도록 무효화

    if (!_commandInProgress) {
      unawaited(_unloadForBackground());
    }
  }

  void _finishCommand() {
    _commandInProgress = false;

    if (mounted && _backgroundStopPending) {
      unawaited(_unloadForBackground());
    }
  }

  Future<void> _unloadForBackground() async {
    _commandInProgress = true;
    state = const PostAudioPreviewState.loading();

    try {
      await _player.unloadFile();
      _loadedPath = null;
      if (mounted) state = const PostAudioPreviewState.idle();
    } catch (_) {
      _showFailure();
    } finally {
      _backgroundStopPending = false;
      _commandInProgress = false;
    }
  }

  Future<void> play(String filePath) async {
    if (!mounted || _commandInProgress || state is PostAudioPreviewPlaying) {
      return;
    }

    _commandInProgress = true;
    final requestId = ++_playRequestId;
    final replay = state is PostAudioPreviewCompleted;
    _acceptPlaybackEvents = false;
    state = const PostAudioPreviewState.loading();

    try {
      if (_loadedPath != filePath) {
        await _player.loadFile(filePath);
        if (!mounted || requestId != _playRequestId) return;
        _loadedPath = filePath;
      } else if (replay) {
        await _player.pause();
        if (!mounted || requestId != _playRequestId) return;
        await _player.seekToStart();
      }

      if (!mounted || requestId != _playRequestId) return;

      _acceptPlaybackEvents = true;
      // play()는 재생이 끝나거나 멈출 때 완료되므로 여기서 기다리지 않아.
      unawaited(_playAndHandleFailure(requestId));
    } catch (_) {
      if (requestId == _playRequestId) _showFailure();
    } finally {
      _finishCommand();
    }
  }

  Future<void> _playAndHandleFailure(int requestId) async {
    try {
      await _player.play();
    } catch (_) {
      if (requestId == _playRequestId) _showFailure();
    }
  }

  Future<void> pause() async {
    if (!mounted || _commandInProgress || state is! PostAudioPreviewPlaying) {
      return;
    }

    _commandInProgress = true;
    try {
      await _player.pause();
    } catch (_) {
      _showFailure();
    } finally {
      _finishCommand();
    }
  }

  void _onPlaybackChanged(({bool playing, bool completed}) event) {
    if (!mounted || !_acceptPlaybackEvents) return;

    if (event.completed) {
      state = const PostAudioPreviewState.completed();
    } else if (event.playing) {
      state = const PostAudioPreviewState.playing();
    } else if (state is PostAudioPreviewPlaying) {
      state = const PostAudioPreviewState.paused();
    }
  }

  void _showFailure() {
    if (!mounted || state is PostAudioPreviewIdle) return;

    _playRequestId++;
    _acceptPlaybackEvents = false;
    _loadedPath = null;
    state = const PostAudioPreviewState.failure();
  }

  @override
  void dispose() {
    _acceptPlaybackEvents = false;
    super.dispose();
    unawaited(_release());
  }

  Future<void> _release() async {
    try {
      await _changes.cancel();
      await _errors.cancel();
    } finally {
      await _player.dispose();
    }
  }

  Future<void> discardClip(Future<void> Function() deleteRecording) async {
    if (!mounted || _commandInProgress) return;

    _commandInProgress = true;
    _acceptPlaybackEvents = false;
    _playRequestId++; // 이전 재생 작업에서 늦게 오는 결과는 무시
    state = const PostAudioPreviewState.loading();

    try {
      await _player.unloadFile();
      _loadedPath = null;

      if (!mounted) return;
      await deleteRecording();

      if (mounted) state = const PostAudioPreviewState.idle();
    } catch (_) {
      // 플레이어 정리 실패 시에는 파일을 지우지 않는다
      _showFailure();
    } finally {
      _finishCommand();
    }
  }
}
