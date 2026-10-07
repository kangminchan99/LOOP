import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';

part 'user_coupon_list_model.freezed.dart';
part 'user_coupon_list_model.g.dart';

@freezed
abstract class UserCouponListModel with _$UserCouponListModel {
  const factory UserCouponListModel({
    // 이번 페이지에서 조회한 본인 쿠폰 목록
    required List<UserCouponModel> items,

    // 다음 페이지 커서. 마지막 페이지라면 null
    required String? nextCursor,

    // 다음 페이지가 있는지
    required bool hasNext,

    // 서버가 응답에 포함한 DB 기준 시각
    required DateTime serverTime,
  }) = _UserCouponListModel;

  factory UserCouponListModel.fromJson(Map<String, dynamic> json) =>
      _$UserCouponListModelFromJson(json);
}
