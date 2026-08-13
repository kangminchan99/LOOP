import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/localization/locale_provider.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/attendance/presentation/widgets/attendance_dialog_widget.dart';
import 'package:loop/src/features/settings/domain/models/setting_model.dart';

import 'setting_item_widget.dart';

class SettingSectionWidget extends ConsumerWidget {
  final SettingSection section;
  final VoidCallback? onLanguageTap;
  final VoidCallback? onThemeModeTap;

  const SettingSectionWidget({
    super.key,
    required this.section,
    this.onLanguageTap,
    this.onThemeModeTap,
  });

  String _sectionTitle(AppLocalizations l10n, String title) {
    return switch (title) {
      '계정' => l10n.settingsAccount,
      '커뮤니티' => l10n.settingsCommunity,
      '앱 설정' => l10n.settingsAppSettings,
      '지원' => l10n.settingsSupport,
      _ => title,
    };
  }

  String _itemLabel(AppLocalizations l10n, String label) {
    return switch (label) {
      '내 댓글' => l10n.settingsMyComments,
      '출석 체크' => l10n.settingsAttendanceCheck,
      '알림 목록' => l10n.settingsNotificationList,
      '차단한 사용자' => l10n.settingsBlockedUsers,
      '저장한 글' => l10n.settingsSavedPosts,
      '알림 설정' => l10n.settingsNotificationSettings,
      '화면 모드' => l10n.settingsDisplayMode,
      '언어' => l10n.settingsLanguage,
      '공지사항' => l10n.settingsNotice,
      '문의하기' => l10n.settingsContact,
      '약관 및 개인정보 처리방침' => l10n.settingsTermsPrivacy,
      _ => label,
    };
  }

  String? _itemValue({
    required AppLocalizations l10n,
    required SettingItem item,
    required Locale currentLocale,
  }) {
    if (item.label == '언어') {
      return currentLocale.languageCode == 'en'
          ? l10n.settingsEnglish
          : l10n.settingsKorean;
    }

    if (item.value == '켜짐') return l10n.settingsOn;
    if (item.value == '시스템') return l10n.settingsSystem;

    return item.value.isNotEmpty ? item.value : null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            _sectionTitle(l10n, section.title),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ).copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: theme.colorScheme.surface,
            border: Border.all(color: theme.dividerColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: List.generate(section.items.length, (index) {
              final item = section.items[index];
              final isLast = index == section.items.length - 1;
              return SettingItemWidget(
                icon: item.icon,
                label: _itemLabel(l10n, item.label),
                value: _itemValue(
                  l10n: l10n,
                  item: item,
                  currentLocale: currentLocale,
                ),
                onTap: () {
                  if (item.label == '출석 체크') {
                    showDialog(
                      context: context,
                      builder: (_) => const AttendanceDialog(),
                    );
                    return;
                  } else if (item.label == '내 댓글') {
                    context.pushNamed(AppRoute.commentList.name);
                    return;
                  } else if (item.label == '알림 목록') {
                    // Navigate to the notification list page
                    context.pushNamed(AppRoute.notifications.name);
                    return;
                  } else if (item.label == '언어') {
                    onLanguageTap?.call();
                    return;
                  } else if (item.label == '화면 모드') {
                    onThemeModeTap?.call();
                    return;
                  }

                  item.onTap?.call();
                },
                showDivider: !isLast,
              );
            }),
          ),
        ),
      ],
    );
  }
}
