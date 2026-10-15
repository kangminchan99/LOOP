import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/coupons/domain/failures/coupon_issue_unconfirmed_failure.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_coupon_event_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/get_my_coupon_usecase.dart';
import 'package:loop/src/features/coupons/domain/usecases/issue_coupon_usecase.dart';
import 'package:loop/src/features/coupons/presentation/providers/coupon_event_detail_state.dart';

class CouponEventDetailNotifier extends StateNotifier<CouponEventDetailState> {
  CouponEventDetailNotifier({
    required this.eventId,
    required GetCouponEventUseCase getCouponEventUseCase,
    required GetMyCouponUseCase getMyCouponUseCase,
    required IssueCouponUseCase issueCouponUseCase,
    required bool Function() isSessionCurrent,
  }) : _getCouponEventUseCase = getCouponEventUseCase,
       _getMyCouponUseCase = getMyCouponUseCase,
       _issueCouponUseCase = issueCouponUseCase,
       _isSessionCurrent = isSessionCurrent,
       super(const CouponEventDetailState());

  final int eventId;

  final GetCouponEventUseCase _getCouponEventUseCase;
  final GetMyCouponUseCase _getMyCouponUseCase;
  final IssueCouponUseCase _issueCouponUseCase;
  final bool Function() _isSessionCurrent;

  // 종료된 객체나 이전 로그인 세션의 결과를 반영하지 않는다.
  bool get _canUpdate => mounted && _isSessionCurrent();

  Future<void> load() async {
    if (!_canUpdate || state.isLoading || state.isIssuing) {
      return;
    }

    // 기존 정보를 유지하면서 조회를 시작한다.
    state = state.copyWith(isLoading: true, loadFailure: null);

    // 1. 이벤트를 조회한다.
    final eventResult = await _getCouponEventUseCase(eventId: eventId);

    if (!_canUpdate) return;

    final event = eventResult.fold<CouponEventModel?>((failure) {
      state = state.copyWith(isLoading: false, loadFailure: failure);
      return null;
    }, (event) => event);

    // 이벤트 조회가 실패했다면 본인 쿠폰 조회도 진행하지 않는다.
    if (event == null) return;

    // 2. 해당 이벤트의 본인 발급 여부를 조회한다.
    final couponResult = await _getMyCouponUseCase(eventId: eventId);

    if (!_canUpdate) return;

    couponResult.fold(
      (failure) {
        // 조회 실패를 미발급으로 바꾸지 않는다.
        state = state.copyWith(isLoading: false, loadFailure: failure);
      },
      (coupon) {
        // 두 조회가 모두 성공했을 때 함께 반영한다.
        // coupon이 null이면 조회 시점에 발급된 쿠폰이 없는 것이다.
        state = state.copyWith(
          event: event,
          myCoupon: coupon,
          isLoading: false,
          hasLoaded: true,
          loadFailure: null,
          issueFailure: coupon != null ? null : state.issueFailure,
        );
      },
    );
  }

  Future<void> issue({bool retryUnconfirmed = false}) async {
    // 조회 완료 전이나 다른 작업 진행 중에는 발급하지 않는다.
    if (!_canUpdate ||
        state.isLoading ||
        state.isIssuing ||
        !state.hasLoaded ||
        state.event == null ||
        state.loadFailure != null) {
      return;
    }

    if (state.myCoupon != null) return;

    // 미확정 상태에서는 사용자가 명시적으로 재시도한 경우만 허용한다.
    if (state.issueFailure is CouponIssueUnconfirmedFailure &&
        !retryUnconfirmed) {
      return;
    }

    // 첫 await 전에 설정해 연속 클릭을 막는다.
    state = state.copyWith(isIssuing: true, issueFailure: null);

    final result = await _issueCouponUseCase(
      eventId: eventId,
      isSessionCurrent: () => _canUpdate,
    );

    if (!_canUpdate) return;

    result.fold(
      (failure) {
        // 기존 이벤트 정보는 유지하고 발급 오류만 반영한다.
        state = state.copyWith(isIssuing: false, issueFailure: failure);
      },
      (coupon) {
        // 서버가 확인해준 쿠폰을 저장한다.
        state = state.copyWith(
          myCoupon: coupon,
          isIssuing: false,
          issueFailure: null,
        );
      },
    );
  }

  // 결과가 불확실한 발급 요청을 조회로 다시 확인한다.
  Future<void> confirmIssue() async {
    if (!_canUpdate ||
        state.isLoading ||
        state.isIssuing ||
        state.issueFailure is! CouponIssueUnconfirmedFailure) {
      return;
    }

    // 재확인 중에도 버튼 연속 클릭을 막는다.
    state = state.copyWith(isIssuing: true);

    final result = await _getMyCouponUseCase(eventId: eventId);

    if (!_canUpdate) return;

    result.fold(
      (_) {
        // 조회도 실패했다면 결과 미확정 상태를 유지한다.
        state = state.copyWith(
          isIssuing: false,
          issueFailure: const CouponIssueUnconfirmedFailure(),
        );
      },
      (coupon) {
        state = state.copyWith(
          myCoupon: coupon,
          isIssuing: false,

          // 쿠폰이 확인된 경우에만 미확정 상태를 해제한다.
          issueFailure: coupon == null
              ? const CouponIssueUnconfirmedFailure()
              : null,
        );
      },
    );
  }
}
