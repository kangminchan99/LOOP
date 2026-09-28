import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class SettingProfileCardWidget extends StatelessWidget {
  const SettingProfileCardWidget({
    super.key,
    required this.user,
    this.onEditTap,
    this.isUpdating = false,
  });
  final UserModel user;
  final VoidCallback? onEditTap;
  final bool isUpdating;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final url = user.profileImageUrl;
    Widget placeholder() => ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: const Center(child: Icon(Icons.person_outline, size: 32)),
    );
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child:
                        url == null || url.isEmpty
                            ? placeholder()
                            : CachedNetworkImage(
                              imageUrl: url,
                              fit: BoxFit.cover,
                              memCacheWidth: 192,
                              placeholder: (_, _) => placeholder(),
                              // 이미지 실패는 인증 상태를 변경하지 않는다.
                              errorWidget: (_, _, _) => placeholder(),
                            ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.nickname, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(user.email ?? l10n.settingsNoEmail),
                      const SizedBox(height: 4),
                      Text(l10n.settingsPointCount(user.point)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onEditTap,
              icon:
                  isUpdating
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                      : const Icon(Icons.edit_outlined),
              label: Text(
                isUpdating ? l10n.settingsProcessing : l10n.settingsEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
