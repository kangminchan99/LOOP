import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

class PostCacheStatus extends StatelessWidget {
  const PostCacheStatus({
    super.key,
    required this.isFromCache,
    required this.isOffline,
    required this.isBusy,
    required this.hasError,
    required this.onRetry,
  });
  final bool isFromCache;
  final bool isOffline;
  final bool isBusy;
  final bool hasError;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final message = isOffline
        ? l10n.postsConnectionUnavailable
        : hasError
        ? l10n.postsRefreshFailed
        : l10n.postsShowingCache;
    return Semantics(
      liveRegion: true,
      child: Material(
        color: colors.surfaceContainerHighest,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(
                isOffline ? Icons.cloud_off_outlined : Icons.info_outline,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
              ),
              if (hasError)
                TextButton(
                  onPressed: isBusy ? null : onRetry,
                  child: Text(l10n.postsRetry),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
