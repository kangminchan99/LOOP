import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/localization/locale_provider.dart';
import 'package:loop/src/core/theme/theme_mode_provider.dart';
import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';
import 'setting_item_widget.dart';

class SettingsMenuTile extends ConsumerWidget {
  const SettingsMenuTile({
    super.key,
    required this.id,
    required this.onTap,
    this.showDivider = true,
  });
  final SettingsMenuId id;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final supported =
        id != SettingsMenuId.ocr ||
        (!kIsWeb &&
            (defaultTargetPlatform == TargetPlatform.android ||
                defaultTargetPlatform == TargetPlatform.iOS));
    String? value;
    if (!supported) {
      value = l10n.ocrUnsupportedPlatform;
    } else if (!id.isImplemented) {
      value = l10n.settingsComingSoon;
    } else if (id == SettingsMenuId.theme) {
      value = switch (ref.watch(themeModeProvider)) {
        ThemeMode.system => l10n.settingsSystem,
        ThemeMode.light => l10n.settingsLight,
        ThemeMode.dark => l10n.settingsDark,
      };
    } else if (id == SettingsMenuId.language) {
      value =
          ref.watch(localeProvider).languageCode == 'en'
              ? l10n.settingsEnglish
              : l10n.settingsKorean;
    }
    return SettingItemWidget(
      icon: id.icon,
      label: id.label(l10n),
      value: value,
      onTap: supported && id.isImplemented ? onTap : null,
      showDivider: showDivider,
    );
  }
}
