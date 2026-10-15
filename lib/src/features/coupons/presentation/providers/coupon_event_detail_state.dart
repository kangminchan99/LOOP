import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';

part 'coupon_event_detail_state.freezed.dart';

@freezed
abstract class CouponEventDetailState with _$CouponEventDetailState {
  const factory CouponEventDetailState({
    // 이벤트 상세 정보
    CouponEventModel? event,

    // 해당 이벤트에서 본인이 발급받은 쿠폰
    UserCouponModel? myCoupon,

    // 이벤트와 본인 쿠폰 정보를 조회 중인지
    @Default(false) bool isLoading,

    // 두 조회가 모두 성공한 적이 있는지
    @Default(false) bool hasLoaded,

    // 발급 요청 및 이어지는 결과 확인이 진행 중인지
    @Default(false) bool isIssuing,

    // 상세 조회 오류
    Failure? loadFailure,

    // 발급 오류 또는 발급 결과 미확정
    Failure? issueFailure,
  }) = _CouponEventDetailState;
}
