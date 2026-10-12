import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_list_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class GetMyCouponsUseCase {
  const GetMyCouponsUseCase(this._repository);

  final AbstractCouponsRepository _repository;

  // 본인이 발급받은 쿠폰 목록 조회
  Future<Either<Failure, UserCouponListModel>> call({
    int limit = 20,
    String? cursor,
  }) {
    return _repository.getMyCoupons(limit: limit, cursor: cursor);
  }
}
