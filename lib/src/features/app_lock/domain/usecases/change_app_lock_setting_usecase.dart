import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';

import '../repositories/abstract_app_lock_repository.dart';
import 'authenticate_app_lock_usecase.dart';

class ChangeAppLockSettingUseCase {
  final AbstractAppLockRepository _repository;
  final AuthenticateAppLockUseCase _authenticate;

  const ChangeAppLockSettingUseCase(this._repository, this._authenticate);

  Future<Either<Failure, bool>> call({
    required int userId,
    required bool enabled,
    required String reason,
    required bool Function() isCurrent,
  }) async {
    // 1. 설정 변경 전 본인 인증
    final authResult = await _authenticate(reason: reason);

    return authResult.fold<Future<Either<Failure, bool>>>(
      (failure) async => Left(failure),
      (authenticated) async {
        // 인증 도중 계정 변경·요청 무효화가 발생하면 저장하지 않음
        if (!authenticated || !isCurrent()) {
          return const Right(false);
        }

        // 3. 인증 성공 후 설정 저장
        final saveResult = await _repository.setEnabled(
          userId: userId,
          enabled: enabled,
        );

        // 4. 저장까지 성공해야 변경 완료
        return saveResult.map((_) => true);
      },
    );
  }
}
