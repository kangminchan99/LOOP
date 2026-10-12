import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class GetCouponEventUseCase {
  const GetCouponEventUseCase(this._repository);

  final AbstractCouponsRepository _repository;

  // 이벤트 ID로 상세 정보를 조회한다.
  Future<Either<Failure, CouponEventModel>> call({required int eventId}) {
    return _repository.getCouponEvent(eventId: eventId);
  }
}
