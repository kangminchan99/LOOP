import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';

import '../models/biometric_capability_model.dart';

abstract class AbstractAppLockRepository {
  // 생체 인증 지원·등록 여부 조회
  Future<Either<Failure, BiometricCapabilityModel>> getBiometricCapability();

  // 인증창을 띄우고 본인 확인
  Future<Either<Failure, bool>> authenticate({required String reason});

  // 진행 중인 인증 취소
  Future<void> stopAuthentication();

  // 계정별 잠금 설정 조회
  Future<Either<Failure, bool>> isEnabled(int userId);

  // 계정별 잠금 설정 저장
  Future<Either<Failure, Unit>> setEnabled({
    required int userId,
    required bool enabled,
  });
}
