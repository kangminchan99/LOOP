import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/coupons/domain/failures/coupon_issue_unconfirmed_failure.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupons_providers.dart';

class CouponEventDetailPage extends ConsumerWidget {
  const CouponEventDetailPage({super.key, required this.eventId});

  final int eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName).add_Hm();

    String formatDate(DateTime value) {
      // 서버에서 받은 시각을 기기의 현지 시간으로 표시한다.
      return dateFormat.format(value.toLocal());
    }

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
    final myCoupon = state.myCoupon;
    final busy = state.isLoading || state.isIssuing;

    final isIssueUnconfirmed =
        state.issueFailure is CouponIssueUnconfirmedFailure;

    // 결과가 미확정이면 일반 발급 대신 별도 재확인 절차를 사용한다.
    final canRequestIssue =
        state.hasLoaded &&
        event != null &&
        myCoupon == null &&
        !busy &&
        state.loadFailure == null;
    final canIssue = canRequestIssue && state.issueFailure == null;

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
                          const SizedBox(height: 24),

                          Text(
                            l10n.couponIssuePeriod,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${formatDate(event.startsAt)}'
                            '\n~ ${formatDate(event.endsAt)}',
                          ),

                          const SizedBox(height: 20),

                          Text(
                            l10n.couponExpiresAt,
                            style: theme.textTheme.titleSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(formatDate(event.couponExpiresAt)),
                          if (myCoupon != null) ...[
                            const SizedBox(height: 24),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 기기 시간이 아닌 서버가 응답한 상태를 표시한다.
                                    Text(
                                      myCoupon.status ==
                                              UserCouponStatus.expired
                                          ? l10n.couponExpired
                                          : l10n.couponIssued,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.couponIssuedAt,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(formatDate(myCoupon.issuedAt)),
                                    const SizedBox(height: 12),
                                    Text(
                                      l10n.couponExpiresAt,
                                      style: theme.textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(formatDate(myCoupon.expiresAt)),
                                  ],
                                ),
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),
                          if (myCoupon == null) ...[
                            FilledButton(
                              onPressed: canIssue
                                  ? () async {
                                      await ref.read(provider.notifier).issue();
                                    }
                                  : null,
                              child: Text(
                                state.isIssuing
                                    ? l10n.couponIssuing
                                    : l10n.couponIssueButton,
                              ),
                            ),

                            if (state.isIssuing) ...[
                              const SizedBox(height: 8),
                              const LinearProgressIndicator(),
                            ],

                            if (state.issueFailure != null) ...[
                              const SizedBox(height: 12),
                              Text(
                                isIssueUnconfirmed
                                    ? l10n.couponIssueUnconfirmed
                                    : l10n.couponIssueFailed,
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              if (isIssueUnconfirmed) ...[
                                // 발급 요청을 반복하지 않고 서버에서 결과만 조회한다.
                                OutlinedButton(
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          await ref
                                              .read(provider.notifier)
                                              .confirmIssue();
                                        },
                                  child: Text(l10n.couponConfirmIssue),
                                ),
                                const SizedBox(height: 8),
                              ],
                              // 사용자가 명시적으로 선택한 경우에만 다시 요청한다.
                              OutlinedButton(
                                onPressed: canRequestIssue
                                    ? () async {
                                        await ref
                                            .read(provider.notifier)
                                            .issue(
                                              retryUnconfirmed:
                                                  isIssueUnconfirmed,
                                            );
                                      }
                                    : null,
                                child: Text(l10n.couponRetryIssue),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.couponRetryIssueHint,
                                style: theme.textTheme.bodySmall,
                              ),
                            ],

                            const SizedBox(height: 16),
                          ],
                          Text(
                            l10n.couponStorageOnlyNotice,
                            style: theme.textTheme.bodySmall,
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
