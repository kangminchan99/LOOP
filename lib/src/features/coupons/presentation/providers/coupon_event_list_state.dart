import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';

part 'coupon_event_list_state.freezed.dart';

@freezed
abstract class CouponEventListState with _$CouponEventListState {
  const factory CouponEventListState({
    // 화면에 표시할 이벤트 목록
    @Default([]) List<CouponEventModel> items,

    // 다음 페이지 정보
    String? nextCursor,
    @Default(false) bool hasNext,

    // 첫 페이지 조회 또는 새로고침 진행 중
    @Default(false) bool isLoading,

    // 다음 페이지 조회 중
    @Default(false) bool isLoadingMore,

    // 첫 페이지 조회에 한 번이라도 성공했는지
    @Default(false) bool hasLoaded,

    // 오류의 종류를 유지하고, 표시 문구는 화면에서 결정
    Failure? failure,

    // 마지막으로 성공한 목록 응답의 서버 시각
    DateTime? serverTime,
  }) = _CouponEventListState;
}
