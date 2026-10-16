import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';

part 'my_coupon_list_state.freezed.dart';

@freezed
abstract class MyCouponListState with _$MyCouponListState {
  const factory MyCouponListState({
    // 화면에 표시할 본인 쿠폰 목록
    @Default([]) List<UserCouponModel> items,

    // 다음 페이지 조회 정보
    String? nextCursor,
    @Default(false) bool hasNext,

    // 첫 조회 또는 새로고침 중
    @Default(false) bool isLoading,

    // 다음 페이지 조회 중
    @Default(false) bool isLoadingMore,

    // 첫 페이지 조회에 성공한 적이 있는지
    @Default(false) bool hasLoaded,

    // 조회 오류. 표시 문구는 화면에서 결정한다.
    Failure? failure,

    // 현재 오류가 다음 페이지 조회에서 발생했는지
    @Default(false) bool isLoadMoreFailure,

    // 마지막으로 성공한 응답의 서버 시각
    DateTime? serverTime,
  }) = _MyCouponListState;
}
