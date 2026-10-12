import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/domain/failures/coupon_issue_unconfirmed_failure.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class IssueCouponUseCase {
  const IssueCouponUseCase(this._repository);

  final AbstractCouponsRepository _repository;

  Future<Either<Failure, UserCouponModel>> call({
    required int eventId,

    // 호출한 쪽에서 작업 시작 당시의 로그인 세션이 유지되는지 확인
    required bool Function() isSessionCurrent,
  }) async {
    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    // 1. 발급 요청은 한 번만 보낸다.
    final result = await _repository.issueCoupon(eventId: eventId);

    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    final failure = result.fold<Failure?>((failure) => failure, (_) => null);

    // 2. 성공했거나 명확한 거절이면 그대로 반환한다.
    if (failure == null || !_needsConfirmation(failure)) {
      return result;
    }

    // 3. 통신 오류 등으로 결과가 불확실하면 조회만 한 번 한다.
    final lookup = await _repository.getMyCoupon(eventId: eventId);

    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    return lookup.fold<Either<Failure, UserCouponModel>>(
      (_) => const Left(CouponIssueUnconfirmedFailure()),
      (coupon) {
        if (coupon != null) {
          return Right(coupon);
        }

        // 최초 발급 요청이 아직 처리 중일 수도 있으므로 실패로 단정하지 않는다.
        return const Left(CouponIssueUnconfirmedFailure());
      },
    );
  }

  bool _needsConfirmation(Failure failure) {
    if (failure is NetworkFailure) {
      return true;
    }

    if (failure is ServerFailure) {
      final status = failure.statusCode;

      // 응답 해석 실패·응답 없음·서버 오류는 결과를 재확인한다.
      return status == null || status >= 500;
    }

    return false;
  }
}
