import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupons_providers.dart';

class CouponEventDetailPage extends ConsumerWidget {
  const CouponEventDetailPage({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final isLoggedIn = ref.watch(
      loginProvider.select((state) => state is LoginSuccess),
    );

    // 비로그인 상태에서는 상세 조회 Provider를 구독하지 않는다.
    if (!isLoggedIn) {
      return DefaultLayout(
        appBarTitle: l10n.couponEventDetailTitle,
        child: Center(child: Text(l10n.couponLoginRequired)),
      );
    }

    // eventId별로 독립적인 상세 상태를 사용한다.
    final provider = couponEventDetailProvider(eventId);
    final state = ref.watch(provider);
    final event = state.event;
    final busy = state.isLoading || state.isIssuing;

    Future<void> refresh() {
      return ref.read(provider.notifier).load();
    }

    return DefaultLayout(
      appBarTitle: l10n.couponEventDetailTitle,
      actions: [
        IconButton(
          tooltip: l10n.couponRefresh,
          onPressed: busy ? null : refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: !state.hasLoaded && state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: refresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        // 재조회 중에는 기존 내용을 유지한다.
                        if (state.isLoading) const LinearProgressIndicator(),

                        if (state.loadFailure != null) ...[
                          Text(
                            state.loadFailure is NetworkFailure
                                ? l10n.couponNetworkError
                                : l10n.couponLoadFailed,
                            textAlign: TextAlign.center,
                          ),
                          TextButton(
                            onPressed: busy ? null : refresh,
                            child: Text(l10n.couponRetry),
                          ),
                          const SizedBox(height: 16),
                        ],

                        if (event != null) ...[
                          Text(
                            event.title,
                            style: theme.textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.couponRemainingCount(event.remainingQuantity),
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.couponIssueNotice,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
