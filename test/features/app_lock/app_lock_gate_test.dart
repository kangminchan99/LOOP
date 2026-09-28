import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_state.dart';
import 'package:loop/src/features/app_lock/presentation/widgets/app_lock_gate.dart';

void main() {
  testWidgets('잠금 중 경로 이동도 가리고 해제하면 해당 경로를 유지한다', (tester) async {
    final state = ValueNotifier(
      const AppLockState(
        userId: 1,
        isEnabled: true,
        isLocked: true,
        isInitializing: false,
      ),
    );
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('목록')),
        ),
        GoRoute(
          path: '/detail',
          builder: (_, _) => const Scaffold(body: Text('상세')),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('ko'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (_, child) => ValueListenableBuilder<AppLockState>(
          valueListenable: state,
          builder: (_, value, _) => AppLockGate(
            state: value,
            userId: 1,
            isRestoringSession: false,
            sessionRestoreFailed: false,
            onUnlock: () => state.value = value.copyWith(isLocked: false),
            onRetry: () {},
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('목록'), findsNothing);
    expect(find.text('잠금 해제'), findsOneWidget);
    router.go('/detail');
    await tester.pumpAndSettle();
    expect(find.text('상세'), findsNothing);
    await tester.tap(find.text('잠금 해제'));
    await tester.pumpAndSettle();
    expect(find.text('상세'), findsOneWidget);
    state.value = state.value.copyWith(userId: 2);
    // 계정 불일치 중에는 끝나지 않는 로딩 애니메이션이 의도된 상태다.
    await tester.pump();
    expect(find.text('상세'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    // 설정 확인 실패가 확정된 경우에만 재시도 버튼을 표시한다.
    state.value = state.value.copyWith(
      failure: const CacheFailure('Test settings load failure'),
    );
    await tester.pumpAndSettle();
    expect(find.text('다시 확인'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
    state.dispose();
  });
}
