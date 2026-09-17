import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/app_lock_failure.dart';
import 'package:loop/src/core/network/error/failures.dart';

import '../repositories/abstract_app_lock_repository.dart';

class AuthenticateAppLockUseCase {
  final AbstractAppLockRepository _repository;

  const AuthenticateAppLockUseCase(this._repository);

  Future<Either<Failure, bool>> call({required String reason}) async {
    // 1. 인증할 때마다 현재 기기 상태 확인
    final result = await _repository.getBiometricCapability();

    return result.fold<Future<Either<Failure, bool>>>(
      // 조회 자체가 실패하면 인증을 진행하지 않음
      (failure) async => Left(failure),
      (capability) async {
        // 2. 생체 인증 지원 여부 확인
        if (!capability.isSupported) {
          return const Left(
            AppLockFailure(
              code: AppLockFailureCode.unsupported,
              message: '생체 인증을 지원하지 않는 기기입니다.',
            ),
          );
        }

        // 3. 지문·얼굴 등록 여부 확인
        if (!capability.isEnrolled) {
          return const Left(
            AppLockFailure(
              code: AppLockFailureCode.notEnrolled,
              message: '기기 설정에서 생체 정보를 등록해주세요.',
            ),
          );
        }

        // 4. 실제 생체 인증 요청
        return _repository.authenticate(reason: reason);
      },
    );
  }
}
