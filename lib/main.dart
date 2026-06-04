import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router.dart';
import 'package:loop/src/core/styles/app_theme.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  // 모든 초기화 완료 대기
  // await Helpers().initializeApp();

  runApp(const ProviderScope(child: LoopApp()));
}

class LoopApp extends ConsumerStatefulWidget {
  const LoopApp({super.key});

  @override
  ConsumerState<LoopApp> createState() => _LoopAppState();
}

class _LoopAppState extends ConsumerState<LoopApp> {
  @override
  void initState() {
    super.initState();
    // 앱 시작 시 세션 복원
    ref.read(loginProvider.notifier).restoreSession();
  }

  @override
  Widget build(BuildContext context) {
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
