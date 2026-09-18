import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';

import '../providers/app_lock_providers.dart';

class AppLockSettingTile extends ConsumerWidget {
  // 설정 화면에서 현재 로그인 계정 ID를 전달받는다.
  final int userId;

  const AppLockSettingTile({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final state = ref.watch(appLockProvider);

    // 현재 계정의 설정을 정상적으로 읽었을 때만 변경 가능.
    final canChange =
        state.userId == userId &&
        state.isEnabled != null &&
        !state.isInitializing &&
        !state.isProcessing &&
        !state.isLocked;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile.adaptive(
        title: Text(l10n.settingsAppLock),
        subtitle: Text(
          state.isInitializing || state.isProcessing
              ? l10n.appLockChecking
              : l10n.settingsAppLockDescription,
        ),
        secondary: const Icon(Icons.fingerprint),

        // 인증·저장이 성공한 상태값으로만 스위치를 표시한다.
        value: state.userId == userId && state.isEnabled == true,

        // 인증 중에는 비활성화하여 중복 요청을 막는다.
        onChanged: canChange
            ? (enabled) async {
                await ref
                    .read(appLockProvider.notifier)
                    .changeEnabled(
                      enabled: enabled,
                      reason: enabled
                          ? l10n.appLockEnableReason
                          : l10n.appLockDisableReason,
                    );
              }
            : null,
      ),
    );
  }
}
