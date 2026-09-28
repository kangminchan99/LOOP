import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

class SettingLoginCardWidget extends StatelessWidget {
  const SettingLoginCardWidget({super.key, this.onLoginTap});
  final VoidCallback? onLoginTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsLoginRequiredTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(l10n.settingsLoginRequiredDescription),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onLoginTap,
              child: Text(l10n.settingsLoginSignup),
            ),
          ],
        ),
      ),
    );
  }
}
