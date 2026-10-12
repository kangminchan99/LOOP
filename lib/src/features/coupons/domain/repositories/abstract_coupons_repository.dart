import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_list_model.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_list_model.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';

abstract interface class AbstractCouponsRepository {
  // 이벤트 목록 조회
  Future<Either<Failure, CouponEventListModel>> getCouponEvents({
    int limit = 20,
    String? cursor,
  });

  // 이벤트 상세 조회
  Future<Either<Failure, CouponEventModel>> getCouponEvent({
    required int eventId,
  });

  // 본인 쿠폰 발급 또는 기존 쿠폰 반환
  Future<Either<Failure, UserCouponModel>> issueCoupon({required int eventId});

  // 본인 발급 확인. 미발급이면 성공 결과로 null 반환
  Future<Either<Failure, UserCouponModel?>> getMyCoupon({required int eventId});

  // 내 쿠폰 목록 조회
  Future<Either<Failure, UserCouponListModel>> getMyCoupons({
    int limit = 20,
    String? cursor,
  });
}
