import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:loop/firebase_options.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/localization/locale_provider.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router.dart';
import 'package:loop/src/core/styles/app_theme.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/notifications/presentation/handlers/notification_navigation_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationNavigationHandler.initialize();

  await dotenv.load(fileName: '.env');

  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_APP_KEY'] ?? '');

  // // key hash 확인용 코드
  // final keyHash = await KakaoSdk.origin;
  // print('KAKAO KEY HASH: $keyHash');

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
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      title: 'Loop',
      scaffoldMessengerKey: snackBarKey,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      themeMode: ThemeMode.system,
      // 앱에서 지원할 언어 목록
      supportedLocales: AppLocalizations.supportedLocales,
      // flutter 기본 위젯들의 번역 설명
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      routerConfig: router,
    );
  }
}
