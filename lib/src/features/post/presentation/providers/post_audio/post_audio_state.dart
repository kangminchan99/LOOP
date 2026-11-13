import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_audio_state.freezed.dart';

enum PostAudioFailure {
  permissionDenied,
  startFailed,
  stopFailed,
  emptyRecording,
  discardFailed,
}

@freezed
sealed class PostAudioState with _$PostAudioState {
  const factory PostAudioState.idle() = PostAudioIdle;

  // 권한 확인, 임시 경로 생성, 녹음 시작을 기다리는 중
  const factory PostAudioState.preparing() = PostAudioPreparing;

  const factory PostAudioState.recording({required Duration elapsed}) =
      PostAudioRecording;

  // 녹음을 멈추고 파일 저장이 끝나기를 기다리는 중
  const factory PostAudioState.stopping() = PostAudioStopping;

  const factory PostAudioState.ready({required String filePath}) =
      PostAudioReady;

  const factory PostAudioState.failure(PostAudioFailure reason) =
      PostAudioFailed;
}
