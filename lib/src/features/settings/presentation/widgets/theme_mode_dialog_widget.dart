import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/theme/theme_mode_provider.dart';
import 'preference_choice_dialog.dart';

class ThemeModeDialogWidget extends ConsumerWidget {
  const ThemeModeDialogWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PreferenceChoiceDialog<ThemeMode>(
      title: l10n.settingsDisplayMode,
      values: const [ThemeMode.system, ThemeMode.light, ThemeMode.dark],
      selected: ref.watch(themeModeProvider),
      label:
          (value) => switch (value) {
            ThemeMode.system => l10n.settingsSystem,
            ThemeMode.light => l10n.settingsLight,
            ThemeMode.dark => l10n.settingsDark,
          },
      onChanged:
          (value) =>
              ref.read(themeModeProvider.notifier).changeThemeMode(value),
    );
  }
}
