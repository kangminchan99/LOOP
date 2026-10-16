import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_my_coupons_usecase.dart';
import 'package:loop/src/features/coupons/presentation/providers/my_coupon_list_state.dart';

class MyCouponListNotifier extends StateNotifier<MyCouponListState> {
  MyCouponListNotifier({
    required GetMyCouponsUseCase getMyCouponsUseCase,
    required bool Function() isSessionCurrent,
  }) : _getMyCouponsUseCase = getMyCouponsUseCase,
       _isSessionCurrent = isSessionCurrent,
       super(const MyCouponListState());

  final GetMyCouponsUseCase _getMyCouponsUseCase;
  final bool Function() _isSessionCurrent;

  // 화면 종료나 로그인 세션 변경 후에는 결과를 반영하지 않는다.
  bool get _canUpdate => mounted && _isSessionCurrent();

  Future<void> load() async {
    // 조회가 진행 중이면 중복 요청하지 않는다.
    if (!_canUpdate || state.isLoading || state.isLoadingMore) {
      return;
    }

    // 새로고침 중에도 기존 목록은 유지한다.
    state = state.copyWith(
      isLoading: true,
      failure: null,
      isLoadMoreFailure: false,
    );

    // 커서 없이 호출하면 첫 페이지를 조회한다.
    final result = await _getMyCouponsUseCase();

    if (!_canUpdate) return;

    result.fold(
      (failure) {
        // 실패하면 기존 목록을 유지하고 오류만 반영한다.
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (page) {
        // 첫 페이지 결과로 목록과 페이지 정보를 교체한다.
        state = state.copyWith(
          items: page.items,
          nextCursor: page.nextCursor,
          hasNext: page.hasNext,
          isLoading: false,
          hasLoaded: true,
          failure: null,
          serverTime: page.serverTime,
        );
      },
    );
  }

  Future<void> loadMore() async {
    // 첫 조회 성공 후, 다음 페이지가 있을 때만 요청한다.
    if (!_canUpdate ||
        !state.hasLoaded ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasNext) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null) return;

    state = state.copyWith(
      isLoadingMore: true,
      failure: null,
      isLoadMoreFailure: false,
    );

    final result = await _getMyCouponsUseCase(cursor: cursor);

    if (!_canUpdate) return;

    result.fold(
      (failure) {
        // 실패해도 기존 목록과 커서를 유지해 다시 시도할 수 있다.
        state = state.copyWith(
          isLoadingMore: false,
          failure: failure,
          isLoadMoreFailure: true,
        );
      },
      (page) {
        // 쿠폰 ID로 합쳐 중복 표시를 방지한다.
        final couponsById = {
          for (final coupon in state.items) coupon.id: coupon,
        };

        for (final coupon in page.items) {
          couponsById[coupon.id] = coupon;
        }

        state = state.copyWith(
          items: couponsById.values.toList(),
          nextCursor: page.nextCursor,
          hasNext: page.hasNext,
          isLoadingMore: false,
          failure: null,
          serverTime: page.serverTime,
        );
      },
    );
  }
}
