import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupons_providers.dart';

class CouponEventListPage extends ConsumerWidget {
  const CouponEventListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    final isLoggedIn = ref.watch(
      loginProvider.select((state) => state is LoginSuccess),
    );

    // 로그인하지 않았다면 목록 Provider를 구독하지 않는다.
    if (!isLoggedIn) {
      return DefaultLayout(
        appBarTitle: l10n.couponEventsTitle,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(l10n.couponLoginRequired),
          ),
        ),
      );
    }

    final state = ref.watch(couponEventListProvider);
    final busy = state.isLoading || state.isLoadingMore;

    Future<void> refresh() {
      return ref.read(couponEventListProvider.notifier).load();
    }

    return DefaultLayout(
      appBarTitle: l10n.couponEventsTitle,
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
          // 넓은 화면에서도 목록이 지나치게 늘어나지 않게 한다.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              children: [
                // 새로고침 중에도 기존 목록을 유지한다.
                if (state.isLoading && state.hasLoaded)
                  const LinearProgressIndicator(),

                // 서버 메시지를 그대로 출력하지 않고 번역 문구를 사용한다.
                if (state.failure != null)
                  Padding(
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
                          onPressed: busy ? null : refresh,
                          child: Text(l10n.couponRetry),
                        ),
                      ],
                    ),
                  ),

                Expanded(
                  child: !state.hasLoaded && state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : RefreshIndicator(
                          onRefresh: refresh,
                          child: ListView.builder(
                            // 목록이 짧거나 비어도 당겨서 새로고침할 수 있다.
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            itemCount: state.items.length + 1,
                            itemBuilder: (context, index) {
                              if (index < state.items.length) {
                                final event = state.items[index];

                                return Card(
                                  key: ValueKey(event.id),
                                  child: ListTile(
                                    title: Text(
                                      event.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    subtitle: Text(
                                      l10n.couponRemainingCount(
                                        event.remainingQuantity,
                                      ),
                                    ),
                                  ),
                                );
                              }

                              // 마지막 항목은 빈 목록 안내 또는 추가 조회 영역이다.
                              if (state.items.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Text(
                                    state.hasLoaded
                                        ? l10n.couponEventsEmpty
                                        : '',
                                    textAlign: TextAlign.center,
                                  ),
                                );
                              }

                              if (state.isLoadingMore) {
                                return const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              if (!state.hasNext) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: OutlinedButton(
                                  onPressed: busy
                                      ? null
                                      : () {
                                          ref
                                              .read(
                                                couponEventListProvider
                                                    .notifier,
                                              )
                                              .loadMore();
                                        },
                                  child: Text(l10n.couponLoadMore),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
