import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_audio_preview_state.freezed.dart';

@freezed
sealed class PostAudioPreviewState with _$PostAudioPreviewState {
  const factory PostAudioPreviewState.idle() = PostAudioPreviewIdle;
  const factory PostAudioPreviewState.loading() = PostAudioPreviewLoading;
  const factory PostAudioPreviewState.playing() = PostAudioPreviewPlaying;
  const factory PostAudioPreviewState.paused() = PostAudioPreviewPaused;
  const factory PostAudioPreviewState.completed() = PostAudioPreviewCompleted;
  const factory PostAudioPreviewState.failure() = PostAudioPreviewFailed;
}
