import 'package:freezed_annotation/freezed_annotation.dart';

part 'coupon_event_model.freezed.dart';
part 'coupon_event_model.g.dart';

@freezed
abstract class CouponEventModel with _$CouponEventModel {
  const factory CouponEventModel({
    // 이벤트 기본 정보
    required int id,
    required String title,

    // 전체 수량·발급량·조회 당시 잔여량
    required int totalQuantity,
    required int issuedCount,
    required int remainingQuantity,

    // 관리자가 신규 발급을 허용했는지
    required bool isActive,

    // 쿠폰을 발급받을 수 있는 기간
    required DateTime startsAt,
    required DateTime endsAt,

    // 발급된 쿠폰 자체의 만료 시각
    required DateTime couponExpiresAt,

    required DateTime createdAt,
    required DateTime updatedAt,

    // 서버가 응답에 포함한 DB 기준 시각
    required DateTime serverTime,
  }) = _CouponEventModel;

  factory CouponEventModel.fromJson(Map<String, dynamic> json) =>
      _$CouponEventModelFromJson(json);
}
