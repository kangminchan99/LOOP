import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_coupon_model.freezed.dart';
part 'user_coupon_model.g.dart';

// 서버의 상태 문자열을 앱에서 사용할 enum으로 변환한다.
enum UserCouponStatus {
  @JsonValue('ISSUED')
  issued,

  @JsonValue('EXPIRED')
  expired,
}

@freezed
abstract class UserCouponModel with _$UserCouponModel {
  const factory UserCouponModel({
    // 발급된 쿠폰 자체의 ID
    required int id,

    // 쿠폰을 발급한 이벤트 정보
    required int eventId,
    required String eventTitle,

    // 발급 시각과 만료 시각
    required DateTime issuedAt,
    required DateTime expiresAt,

    // 서버가 판단한 발급·만료 상태
    required UserCouponStatus status,

    // 응답 시점의 DB 기준 시각
    required DateTime serverTime,
  }) = _UserCouponModel;

  factory UserCouponModel.fromJson(Map<String, dynamic> json) =>
      _$UserCouponModelFromJson(json);
}
