import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

import '../providers/app_lock_state.dart';
import 'app_lock_screen.dart';

// Navigator를 유지하면서 화면 노출·포커스·애니메이션을 차단한다.
class AppLockGate extends StatelessWidget {
  final Widget child;
  final AppLockState state;
  final int? userId;
  final bool isRestoringSession;
  final bool sessionRestoreFailed;
  final VoidCallback onUnlock;
  final VoidCallback onRetry;

  const AppLockGate({
    super.key,
    required this.child,
    required this.state,
    required this.userId,
    required this.isRestoringSession,
    required this.sessionRestoreFailed,
    required this.onUnlock,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sameAccount = userId != null && state.userId == userId;
    // 오류가 있으면 로딩 대신 재시도 화면을 표시한다.
    final isChecking =
        !sessionRestoreFailed &&
        (isRestoringSession ||
            (userId != null &&
                state.failure == null &&
                (!sameAccount || state.isInitializing)));
    final blocked =
        isRestoringSession ||
        sessionRestoreFailed ||
        (userId != null &&
            (!sameAccount ||
                state.isInitializing ||
                state.isEnabled == null ||
                state.isLocked));
    final busy =
        isRestoringSession ||
        (!sessionRestoreFailed &&
            userId != null &&
            (state.isInitializing || state.isProcessing));
    final canUnlock =
        !sessionRestoreFailed &&
        sameAccount &&
        !state.isInitializing &&
        state.isEnabled == true;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 숨긴 화면의 키보드 입력과 애니메이션도 차단한다.
        Offstage(
          offstage: blocked,
          child: ExcludeFocus(
            excluding: blocked,
            child: TickerMode(enabled: !blocked, child: child),
          ),
        ),
        if (blocked)
          Positioned.fill(
            child: ScaffoldMessenger(
              child: isChecking
                  // 설정 확인 중에는 잠금 안내 없이 로딩만 표시
                  ? Scaffold(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      body: const Center(child: CircularProgressIndicator()),
                    )
                  // 확인이 끝난 뒤 잠금 또는 오류 화면 표시
                  : AppLockScreen(
                      title: l10n.appLockTitle,
                      description: busy
                          ? l10n.appLockChecking
                          : l10n.appLockDescription,
                      buttonLabel: canUnlock
                          ? l10n.appLockUnlock
                          : l10n.appLockRetry,
                      isBusy: busy,

                      errorMessage: sessionRestoreFailed
                          ? l10n.appLockError
                          : state.failure?.errorMessage,
                      onPressed: busy ? null : (canUnlock ? onUnlock : onRetry),
                    ),
            ),
          ),
      ],
    );
  }
}
