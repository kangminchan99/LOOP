import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class PostAudioRecorderDataSource {
  AudioRecorder? _recorder;
  Directory? _recordingDirectory;
  bool _recordingMayBeActive = false;

  // 화면이 상태만 구독할 때는 네이티브 녹음기를 만들지 않는다.
  AudioRecorder get _activeRecorder => _recorder ??= AudioRecorder();

  Future<bool> requestPermission() => _activeRecorder.hasPermission();

  Future<String> createRecordingPath() async {
    final cacheDirectory = await getTemporaryDirectory();
    final recordingDirectory = await cacheDirectory.createTemp('post_audio_');
    _recordingDirectory = recordingDirectory;

    return '${recordingDirectory.path}/clip.m4a';
  }

  Future<void> start({required String path}) async {
    // 시작 도중 예외가 나도 정리할 때 녹음기 종료를 시도한다.
    _recordingMayBeActive = true;
    await _activeRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        numChannels: 1, // 짧은 음성은 모노로 녹음
        audioInterruption: AudioInterruptionMode.pause,
      ),
      path: path,
    );
  }

  Future<String?> stop() async {
    final path = await _recorder?.stop();
    _recordingMayBeActive = false;
    if (path == null || path.isEmpty) return null;

    final file = File(path);
    return await file.exists() && await file.length() > 0 ? path : null;
  }

  Future<void> discardRecording() async {
    if (_recordingMayBeActive) await cancel();

    final directory = _recordingDirectory;
    if (directory == null) return;

    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
    _recordingDirectory = null;
  }

  // 진행 중인 녹음을 취소하고 파일을 버리기
  Future<void> cancel() async {
    await _recorder?.cancel();
    _recordingMayBeActive = false;
  }

  Future<void> dispose() async {
    await _recorder?.dispose();
    _recorder = null;
  }
}
