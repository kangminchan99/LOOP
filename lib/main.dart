import 'dart:async';

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
import 'package:loop/src/core/theme/theme_mode_provider.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_providers.dart';
import 'package:loop/src/features/app_lock/presentation/widgets/app_lock_gate.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
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

class _LoopAppState extends ConsumerState<LoopApp> with WidgetsBindingObserver {
  // 이전 계정의 초기화 작업을 구분
  int _sessionSyncId = 0;
  bool _isRestoringSession = true;
  bool _sessionRestoreFailed = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 로그인 성공 상태에서 계정 ID만 관찰
    ref.listenManual<int?>(
      loginProvider.select(
        (state) => state is LoginSuccess ? state.user.id : null,
      ),
      (previous, next) {
        unawaited(_syncAppLockSession(next));
      },
      fireImmediately: true,
    );

    // 리스너를 연결한 다음 세션 복원
    unawaited(_restoreSession());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    // Android·iOS에서 앱이 백그라운드로 이동하면 잠근다.
    if (state == AppLifecycleState.paused) {
      ref.read(appLockProvider.notifier).lock();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _restoreSession() async {
    try {
      await ref.read(loginProvider.notifier).restoreSession();
    } catch (_) {
      if (mounted) _sessionRestoreFailed = true;
    } finally {
      if (mounted) {
        setState(() => _isRestoringSession = false);
      }
    }
  }

  Future<void> _retryAppLock() async {
    if (!mounted || _isRestoringSession) return;
    if (_sessionRestoreFailed) {
      setState(() {
        _sessionRestoreFailed = false;
        _isRestoringSession = true;
      });
      await _restoreSession();
      return;
    }
    final login = ref.read(loginProvider);
    if (login is LoginSuccess) {
      await _syncAppLockSession(login.user.id);
    }
  }

  Future<void> _syncAppLockSession(int? userId) async {
    if (!mounted) return;

    final syncId = ++_sessionSyncId;
    final notifier = ref.read(appLockProvider.notifier);

    // 이전 계정의 상태와 진행 중인 인증 정리
    final resetCompleted = await notifier.reset();

    // 기다리는 동안 계정이 다시 바뀌었다면 중단
    if (!mounted || syncId != _sessionSyncId || !resetCompleted) {
      return;
    }

    // 로그인하지 않은 상태에서는 설정을 조회하지 않음
    if (userId == null) return;

    // 로그인 계정의 저장된 잠금 설정 조회
    await notifier.initialize(userId);
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'Loop',
      scaffoldMessengerKey: snackBarKey,
      theme: lightAppTheme,
      darkTheme: darkAppTheme,
      themeMode: themeMode,
      // 앱에서 지원할 언어 목록
      supportedLocales: AppLocalizations.supportedLocales,
      // flutter 기본 위젯들의 번역 설명
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      locale: locale,
      routerConfig: router,
      // 경로를 교체하지 않고 모든 화면과 다이얼로그 앞에서 보호한다.
      builder: (context, child) => Consumer(
        builder: (context, ref, _) {
          final login = ref.watch(loginProvider);
          final lock = ref.watch(appLockProvider);
          final l10n = AppLocalizations.of(context);
          return AppLockGate(
            state: lock,
            userId: login is LoginSuccess ? login.user.id : null,
            isRestoringSession: _isRestoringSession,
            sessionRestoreFailed: _sessionRestoreFailed,
            onUnlock: () => unawaited(
              ref
                  .read(appLockProvider.notifier)
                  .unlock(reason: l10n.appLockReason),
            ),
            onRetry: () => unawaited(_retryAppLock()),
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
