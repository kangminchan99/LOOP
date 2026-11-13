import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_audio_player_data_source.dart';

import 'post_audio_preview_notifier.dart';
import 'post_audio_preview_state.dart';

final postAudioPreviewProvider = StateNotifierProvider.autoDispose
    .family<PostAudioPreviewNotifier, PostAudioPreviewState, Object>(
      (ref, sessionKey) =>
          PostAudioPreviewNotifier(PostAudioPlayerDataSource()),
    );
