import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';

part 'coupon_event_list_model.freezed.dart';
part 'coupon_event_list_model.g.dart';

@freezed
abstract class CouponEventListModel with _$CouponEventListModel {
  const factory CouponEventListModel({
    // 이번 페이지의 이벤트 목록
    required List<CouponEventModel> items,

    // 다음 페이지 조회에 사용할 값. 마지막 페이지라면 null
    required String? nextCursor,

    // 다음 페이지가 있는지
    required bool hasNext,

    // 서버가 응답에 포함한 DB 기준 시각
    required DateTime serverTime,
  }) = _CouponEventListModel;

  factory CouponEventListModel.fromJson(Map<String, dynamic> json) =>
      _$CouponEventListModelFromJson(json);
}
