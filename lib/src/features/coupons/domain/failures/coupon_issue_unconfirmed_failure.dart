import 'package:loop/src/core/network/error/failures.dart';

// 발급 실패가 아니라, 발급 여부를 아직 확정하지 못한 상태
class CouponIssueUnconfirmedFailure extends Failure {
  const CouponIssueUnconfirmedFailure()
    : super('발급 결과를 확인하지 못했습니다. 잠시 후 다시 확인해주세요.');
}
