import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_preview_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_preview_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_provider.dart';
import 'package:loop/src/features/post/presentation/providers/post_audio/post_audio_state.dart';

class PostAudioRecorderSection extends ConsumerStatefulWidget {
  const PostAudioRecorderSection({required this.sessionKey, super.key});

  final Object sessionKey;

  @override
  ConsumerState<PostAudioRecorderSection> createState() =>
      _PostAudioRecorderSectionState();
}

class _PostAudioRecorderSectionState
    extends ConsumerState<PostAudioRecorderSection> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(onHide: _handleAppHidden);
  }

  void _handleAppHidden() {
    final key = widget.sessionKey;
    final recorderProvider = postAudioProvider(key);
    if (ref.read(recorderProvider) is PostAudioReady) {
      ref.read(postAudioPreviewProvider(key).notifier).stopForBackground();
      return;
    }
    unawaited(ref.read(recorderProvider.notifier).stopForBackground());
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  String _formatElapsed(Duration elapsed) {
    final minutes = elapsed.inMinutes;
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final sessionKey = widget.sessionKey;
    final l10n = AppLocalizations.of(context);
    final provider = postAudioProvider(sessionKey);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    final content = switch (state) {
      PostAudioIdle() => OutlinedButton.icon(
        onPressed: notifier.startRecording,
        icon: const Icon(Icons.mic_none),
        label: Text(l10n.postAudioRecord),
      ),
      PostAudioPreparing() => Text(l10n.postAudioPreparing),
      PostAudioRecording(:final elapsed) => Wrap(
        spacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('${_formatElapsed(elapsed)} / 1:00'),
          FilledButton(
            onPressed: notifier.stopRecording,
            child: Text(l10n.postAudioStop),
          ),
          TextButton(
            onPressed: notifier.discardRecording,
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
        ],
      ),
      PostAudioStopping() => Text(l10n.postAudioStopping),
      PostAudioReady(:final filePath) => Consumer(
        builder: (context, ref, _) {
          final previewProvider = postAudioPreviewProvider(sessionKey);
          final preview = ref.watch(previewProvider);
          final player = ref.read(previewProvider.notifier);

          final isLoading = preview is PostAudioPreviewLoading;
          final isPlaying = preview is PostAudioPreviewPlaying;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.postAudioLocalOnly),
              Wrap(
                spacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: isLoading
                        ? null
                        : isPlaying
                        ? player.pause
                        : () => player.play(filePath),
                    icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                    label: Text(
                      isPlaying ? l10n.postAudioPause : l10n.postAudioPreview,
                    ),
                  ),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => player.discardClip(notifier.discardRecording),
                    child: Text(l10n.postAudioDelete),
                  ),
                ],
              ),
              if (preview is PostAudioPreviewFailed)
                Text(l10n.postAudioPreviewFailed),
            ],
          );
        },
      ),
      PostAudioFailed(:final reason) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reason == PostAudioFailure.permissionDenied
                ? l10n.postAudioPermissionDenied
                : l10n.postAudioFailed,
          ),
          TextButton(
            onPressed: reason == PostAudioFailure.discardFailed
                ? notifier.discardRecording
                : notifier.startRecording,
            child: Text(l10n.postsRetry),
          ),
        ],
      ),
    };

    return Align(alignment: Alignment.centerLeft, child: content);
  }
}
