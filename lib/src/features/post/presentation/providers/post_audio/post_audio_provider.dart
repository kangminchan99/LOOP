import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_recorder_data_source.dart';

import 'post_audio_notifier.dart';
import 'post_audio_state.dart';

// 글쓰기 화면마다 고정된 키를 넘겨 녹음과 임시 파일의 수명을 분리한다.
final postAudioProvider = StateNotifierProvider.autoDispose
    .family<PostAudioNotifier, PostAudioState, Object>((ref, sessionKey) {
      return PostAudioNotifier(PostAudioRecorderDataSource());
    });
