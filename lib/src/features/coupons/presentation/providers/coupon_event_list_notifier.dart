import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_coupon_events_usecase.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_list_state.dart';

class CouponEventListNotifier extends StateNotifier<CouponEventListState> {
  CouponEventListNotifier({
    required GetCouponEventsUseCase getCouponEventsUseCase,
  }) : _getCouponEventsUseCase = getCouponEventsUseCase,
       super(const CouponEventListState());

  final GetCouponEventsUseCase _getCouponEventsUseCase;

  // 첫 페이지 조회 및 새로고침
  Future<void> load() async {
    // 종료된 Notifier이거나 이미 요청 중이면 중복 실행하지 않는다.
    if (!mounted || state.isLoading || state.isLoadingMore) {
      return;
    }

    // 기존 목록은 유지하고 로딩·오류 상태만 변경한다.
    state = state.copyWith(isLoading: true, failure: null);

    // cursor를 생략하면 첫 페이지를 조회한다.
    final result = await _getCouponEventsUseCase();

    // 요청 도중 Notifier가 종료됐다면 결과를 반영하지 않는다.
    if (!mounted) return;

    result.fold(
      (failure) {
        // 새로고침 실패 시 기존 목록을 보존한다.
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

  // 다음 페이지 조회
  Future<void> loadMore() async {
    // 첫 조회가 완료되어야 하며, 다른 조회와 동시에 실행하지 않는다.
    if (!mounted ||
        !state.hasLoaded ||
        state.isLoading ||
        state.isLoadingMore ||
        !state.hasNext) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null) return;

    state = state.copyWith(isLoadingMore: true, failure: null);

    final result = await _getCouponEventsUseCase(cursor: cursor);

    if (!mounted) return;

    result.fold(
      (failure) {
        // 실패하면 기존 목록과 커서를 유지하여 재시도할 수 있게 한다.
        state = state.copyWith(isLoadingMore: false, failure: failure);
      },
      (page) {
        // ID 기준으로 합쳐 같은 이벤트가 중복 표시되지 않게 한다.
        final eventsById = {for (final event in state.items) event.id: event};

        for (final event in page.items) {
          eventsById[event.id] = event;
        }

        state = state.copyWith(
          items: eventsById.values.toList(),
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
