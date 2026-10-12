import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_list_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class GetCouponEventsUseCase {
  const GetCouponEventsUseCase(this._repository);

  final AbstractCouponsRepository _repository;

  // 첫 페이지는 cursor 없이, 다음 페이지는 서버가 준 cursor로 조회한다.
  Future<Either<Failure, CouponEventListModel>> call({
    int limit = 20,
    String? cursor,
  }) {
    return _repository.getCouponEvents(limit: limit, cursor: cursor);
  }
}
