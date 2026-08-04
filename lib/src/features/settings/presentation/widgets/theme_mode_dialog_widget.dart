import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/theme/theme_mode_provider.dart';

class ThemeModeDialogWidget extends ConsumerWidget {
  const ThemeModeDialogWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentThemeMode = ref.watch(themeModeProvider);

    return AlertDialog(
      title: const Text('화면 모드'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('시스템'),
            trailing: currentThemeMode == ThemeMode.system
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref
                  .read(themeModeProvider.notifier)
                  .changeThemeMode(ThemeMode.system);
            },
          ),
          ListTile(
            title: const Text('라이트'),
            trailing: currentThemeMode == ThemeMode.light
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref
                  .read(themeModeProvider.notifier)
                  .changeThemeMode(ThemeMode.light);
            },
          ),
          ListTile(
            title: const Text('다크'),
            trailing: currentThemeMode == ThemeMode.dark
                ? const Icon(Icons.check)
                : null,
            onTap: () {
              ref
                  .read(themeModeProvider.notifier)
                  .changeThemeMode(ThemeMode.dark);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
      ],
    );
  }
}
