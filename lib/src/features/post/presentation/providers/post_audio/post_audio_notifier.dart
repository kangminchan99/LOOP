import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_recorder_data_source.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_state.dart';

class PostAudioNotifier extends StateNotifier<PostAudioState> {
  PostAudioNotifier(this._dataSource, {Stopwatch? stopwatch})
    : _stopwatch = stopwatch ?? Stopwatch(),
      super(const PostAudioState.idle());

  static const _maxDuration = Duration(seconds: 60);
  static final _logger = Logger('PostAudioNotifier');

  final PostAudioRecorderDataSource _dataSource;
  final Stopwatch _stopwatch;
  Timer? _elapsedTimer;
  Timer? _limitTimer;
  Future<void>? _operationDone;

  bool _stopRequestedOnHide = false;

  Future<void> stopForBackground() async {
    if (!mounted) return;
    if (state is PostAudioPreparing) {
      // 진행 중인 시작 작업에서 취소하거나, 이미 시작됐다면 파일을 마무리한다.
      _stopRequestedOnHide = true;
      final starting = _operationDone;
      if (starting != null) await starting;
      return;
    }
    if (state is! PostAudioRecording) return;

    _stopRequestedOnHide = true;
    final pending = _operationDone;
    if (pending != null) await pending;
    if (!_stopRequestedOnHide) return;
    await stopRecording();
  }

  Future<void> startRecording() => _runOperation(_startRecording);
  Future<void> stopRecording() => _runOperation(_stopRecording);
  Future<void> discardRecording() => _runOperation(_discardRecording);

  Future<void> _runOperation(Future<void> Function() action) async {
    if (!mounted || _operationDone != null) return;

    final done = Completer<void>();
    _operationDone = done.future;
    try {
      await action();
    } finally {
      _operationDone = null;
      done.complete();
    }
  }

  void _startTimers() {
    _stopTimers();
    _stopwatch
      ..reset()
      ..start();

    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final current = state;
      if (current is! PostAudioRecording) return;

      final elapsed = _stopwatch.elapsed;
      if (elapsed >= _maxDuration) return;
      final displayed = Duration(seconds: elapsed.inSeconds);
      if (current.elapsed != displayed) {
        state = PostAudioState.recording(elapsed: displayed);
      }
    });

    _limitTimer = Timer(_maxDuration, () => unawaited(stopRecording()));
  }

  void _stopTimers() {
    _elapsedTimer?.cancel();
    _limitTimer?.cancel();
    _elapsedTimer = null;
    _limitTimer = null;
    _stopwatch.stop();
  }

  Future<void> _startRecording() async {
    // 준비 중이거나 이미 녹음 중이면 두 번째 요청은 무시해.
    if (!mounted || (state is! PostAudioIdle && state is! PostAudioFailed)) {
      return;
    }

    _stopRequestedOnHide = false;
    state = const PostAudioState.preparing();

    try {
      final allowed = await _dataSource.requestPermission();
      if (!mounted) return;
      if (_stopRequestedOnHide) {
        state = const PostAudioState.idle();
        return;
      }

      if (!allowed) {
        state = const PostAudioState.failure(PostAudioFailure.permissionDenied);
        return;
      }

      await _dataSource.discardRecording();
      if (!mounted) return;
      if (_stopRequestedOnHide) {
        state = const PostAudioState.idle();
        return;
      }

      final path = await _dataSource.createRecordingPath();
      if (!mounted) return;
      if (_stopRequestedOnHide) {
        await _dataSource.discardRecording();
        if (mounted) state = const PostAudioState.idle();
        return;
      }

      await _dataSource.start(path: path);
      if (!mounted) return;
      if (_stopRequestedOnHide) {
        await _finishRecording();
        return;
      }

      _startTimers();
      state = const PostAudioState.recording(elapsed: Duration.zero);
    } catch (_) {
      await _failAndDiscard(PostAudioFailure.startFailed);
    }
  }

  Future<void> _stopRecording() async {
    if (!mounted || state is! PostAudioRecording) return;

    await _finishRecording();
  }

  Future<void> _finishRecording() async {
    _stopTimers();
    state = const PostAudioState.stopping();

    try {
      final path = await _dataSource.stop();
      if (path == null) {
        await _failAndDiscard(PostAudioFailure.emptyRecording);
        return;
      }

      if (mounted) state = PostAudioState.ready(filePath: path);
    } catch (_) {
      await _failAndDiscard(PostAudioFailure.stopFailed);
    }
  }

  Future<void> _discardRecording() async {
    if (!mounted ||
        (state is! PostAudioRecording &&
            state is! PostAudioReady &&
            state is! PostAudioFailed)) {
      return;
    }

    _stopTimers();
    state = const PostAudioState.stopping();

    try {
      await _dataSource.discardRecording();
      if (mounted) state = const PostAudioState.idle();
    } catch (_) {
      if (mounted) {
        state = const PostAudioState.failure(PostAudioFailure.discardFailed);
      }
    }
  }

  Future<void> _failAndDiscard(PostAudioFailure reason) async {
    _stopTimers();
    try {
      await _dataSource.discardRecording();
    } catch (_) {
      // 원래 실패 원인을 유지한다. 남은 폴더는 다음 작업에서 다시 정리한다.
    }

    if (mounted) state = PostAudioState.failure(reason);
  }

  @override
  void dispose() {
    final pending = _operationDone;
    _stopTimers();
    super.dispose();
    unawaited(_releaseRecorder(pending));
  }

  Future<void> _releaseRecorder(Future<void>? pending) async {
    // 권한 요청, 파일 생성, 녹음기 시작·종료와 정리가 겹치지 않게 한다.
    if (pending != null) await pending;

    try {
      await _dataSource.discardRecording();
    } catch (_) {
      _logger.warning('임시 녹음 정리 실패');
    }

    try {
      await _dataSource.dispose();
    } catch (_) {
      _logger.warning('녹음기 해제 실패');
    }
  }
}
