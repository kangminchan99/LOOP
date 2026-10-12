import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class GetMyCouponUseCase {
  const GetMyCouponUseCase(this._repository);

  final AbstractCouponsRepository _repository;

  // 해당 이벤트에서 본인이 발급받은 쿠폰을 확인한다.
  Future<Either<Failure, UserCouponModel?>> call({required int eventId}) {
    return _repository.getMyCoupon(eventId: eventId);
  }
}
