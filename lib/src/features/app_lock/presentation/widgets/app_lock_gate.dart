import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

import 'app_lock_screen.dart';
import '../providers/app_lock_state.dart';

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
            // 기존 화면의 SnackBar가 잠금 화면에 나타나지 않도록 분리한다.
            child: ScaffoldMessenger(
              child: AppLockScreen(
                title: l10n.appLockTitle,
                description: busy
                    ? l10n.appLockChecking
                    : l10n.appLockDescription,
                buttonLabel: canUnlock ? l10n.appLockUnlock : l10n.appLockRetry,
                isBusy: busy,
                errorMessage: sessionRestoreFailed || state.failure != null
                    ? l10n.appLockError
                    : null,
                onPressed: busy ? null : (canUnlock ? onUnlock : onRetry),
              ),
            ),
          ),
      ],
    );
  }
}
