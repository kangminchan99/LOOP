import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router.dart';
import 'package:loop/src/core/styles/app_theme.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // 모든 초기화 완료 대기
  await Helpers().initializeApp();

  runApp(const ProviderScope(child: LoopApp()));
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
