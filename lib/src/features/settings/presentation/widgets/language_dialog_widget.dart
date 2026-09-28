import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/localization/locale_provider.dart';
import 'preference_choice_dialog.dart';

class LanguageDialogWidget extends ConsumerWidget {
  const LanguageDialogWidget({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return PreferenceChoiceDialog<Locale>(
      title: l10n.languageDialogTitle,
      values: const [Locale('ko'), Locale('en')],
      selected: ref.watch(localeProvider),
      label:
          (value) =>
              value.languageCode == 'en'
                  ? l10n.settingsEnglish
                  : l10n.settingsKorean,
      onChanged:
          (value) => ref.read(localeProvider.notifier).changeLocale(value),
    );
  }
}
