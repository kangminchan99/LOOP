import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/localization/locale_provider.dart';

class LanguageDialogWidget extends ConsumerWidget {
  const LanguageDialogWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return AlertDialog(
      title: Text(l10n.languageDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.settingsKorean),
            trailing:
                currentLocale.languageCode == 'ko'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .changeLocale(const Locale('ko'));
            },
          ),
          ListTile(
            title: Text(l10n.settingsEnglish),
            trailing:
                currentLocale.languageCode == 'en'
                    ? const Icon(Icons.check)
                    : null,
            onTap: () {
              ref
                  .read(localeProvider.notifier)
                  .changeLocale(const Locale('en'));
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.languageDialogClose),
        ),
      ],
    );
  }
}
