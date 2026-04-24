import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router.dart';
import 'package:loop/src/core/styles/app_theme.dart';

void main() {
  runApp(ProviderScope(child: const LoopApp()));
}

class LoopApp extends ConsumerWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Loop',
      scaffoldMessengerKey: snackBarKey,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
