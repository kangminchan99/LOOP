import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_notifier.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_providers.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_state.dart';
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';
import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';
import 'package:loop/src/features/settings/presentation/pages/setting_page.dart';
import 'package:loop/src/features/settings/presentation/providers/settings_actions_notifier.dart';
import 'package:loop/src/features/settings/presentation/providers/settings_actions_provider.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

// 화면 테스트는 인증 SDK/네트워크/생체 인증을 실행하지 않는다.
class FakeLogin extends StateNotifier<LoginState>
    implements LoginStateNotifier {
  FakeLogin(super.state);
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeLock extends StateNotifier<AppLockState> implements AppLockNotifier {
  FakeLock()
    : super(
        const AppLockState(
          userId: 1,
          isEnabled: false,
          isLocked: false,
          isInitializing: false,
        ),
      );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UnusedRepository implements AbstractSettingRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Future<GoRouter> mount(
    WidgetTester tester, {
    required bool loggedIn,
    String role = 'USER',
  }) async {
    final user = loggedIn
        ? UserModel(
            id: 1,
            nickname: 'Test',
            role: role,
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          )
        : null;
    final router = GoRouter(
      initialLocation: '/settings',
      routes: [
        GoRoute(path: '/settings', builder: (_, _) => const SettingPage()),
        GoRoute(
          path: '/ocr',
          name: AppRoute.ocr.name,
          builder: (_, _) => const Scaffold(body: Text('OCR destination')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          loginProvider.overrideWith(
            (ref) => FakeLogin(
              user == null
                  ? const LoginState.initial()
                  : LoginState.success(user),
            ),
          ),
          appLockProvider.overrideWith((ref) => FakeLock()),
          settingsActionsProvider.overrideWith(
            (ref) => SettingsActionsNotifier(
              pickImage: () async => null,
              repository: UnusedRepository(),
              currentUser: () => user,
              sessionRevision: () => 0,
              applyUser: (_) async {},
              unregisterDevice: () async => true,
              logout: () async {},
            ),
          ),
        ],
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('비로그인 설정에 OCR은 없고 Bluetooth는 있다', (tester) async {
    await mount(tester, loggedIn: false);
    expect(find.byKey(const ValueKey(SettingsMenuId.ocr)), findsNothing);
    expect(
      find.byKey(const ValueKey(SettingsMenuId.bluetooth)),
      findsOneWidget,
    );
    expect(find.text('Log in / Sign up'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('OCR을 연타해도 한 번 이동하고 뒤로 가면 설정으로 복귀한다', (tester) async {
    final router = await mount(tester, loggedIn: true);
    final item = find.byKey(const ValueKey(SettingsMenuId.ocr));
    await tester.scrollUntilVisible(item, 250);
    await tester.tap(item);
    await tester.tap(item);
    await tester.pumpAndSettle();
    expect(find.text('OCR destination'), findsOneWidget);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(SettingPage), findsOneWidget);
    expect(router.canPop(), isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('설정 화면 큰 글씨와 좁은 너비에서 레이아웃이 유지된다', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await mount(tester, loggedIn: true, role: 'ADMIN');
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(SettingsMenuId.adminWebView)),
      300,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
