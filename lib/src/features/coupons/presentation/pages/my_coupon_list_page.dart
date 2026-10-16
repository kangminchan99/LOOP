import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupons_providers.dart';

class MyCouponListPage extends ConsumerWidget {
  const MyCouponListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName).add_Hm();

    final isLoggedIn = ref.watch(
      loginProvider.select((state) => state is LoginSuccess),
    );

    // 비로그인 상태에서는 내 쿠폰 목록을 조회하지 않는다.
    if (!isLoggedIn) {
      return DefaultLayout(
        appBarTitle: l10n.myCouponsTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.myCouponsLoginRequired),
          ),
        ),
      );
    }

    final state = ref.watch(myCouponListProvider);
    final busy = state.isLoading || state.isLoadingMore;

    Future<void> refresh() {
      return ref.read(myCouponListProvider.notifier).load();
    }

    Future<void> loadMore() {
      return ref.read(myCouponListProvider.notifier).loadMore();
    }

    return DefaultLayout(
      appBarTitle: l10n.myCouponsTitle,
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
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // 새로고침 중에도 기존 쿠폰 목록을 유지한다.
                        if (state.isLoading)
                          const SliverToBoxAdapter(
                            child: LinearProgressIndicator(),
                          ),

                        if (state.failure != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Text(
                                    state.failure is NetworkFailure
                                        ? l10n.couponNetworkError
                                        : l10n.couponLoadFailed,
                                    textAlign: TextAlign.center,
                                  ),
                                  TextButton(
                                    onPressed: busy
                                        ? null
                                        : state.isLoadMoreFailure
                                        ? loadMore
                                        : refresh,
                                    child: Text(l10n.couponRetry),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // 조회에 성공한 빈 목록만 빈 상태로 안내한다.
                        if (state.hasLoaded && state.items.isEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                l10n.myCouponsEmpty,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        // 보이는 영역에 필요한 카드부터 생성한다.
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final coupon = state.items[index];
                              final expired =
                                  coupon.status == UserCouponStatus.expired;

                              return Card(
                                key: ValueKey(coupon.id),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        coupon.eventTitle,
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        expired
                                            ? l10n.couponStatusExpired
                                            : l10n.couponStatusIssued,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        '${l10n.couponIssuedAt}\n'
                                        '${dateFormat.format(coupon.issuedAt.toLocal())}',
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${l10n.couponExpiresAt}\n'
                                        '${dateFormat.format(coupon.expiresAt.toLocal())}',
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }, childCount: state.items.length),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                if (state.isLoadingMore)
                                  const CircularProgressIndicator()
                                else if (state.hasNext)
                                  OutlinedButton(
                                    onPressed: busy ? null : loadMore,
                                    child: Text(l10n.couponLoadMore),
                                  ),
                                const SizedBox(height: 16),
                                Text(
                                  l10n.couponStorageOnlyNotice,
                                  style: theme.textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
