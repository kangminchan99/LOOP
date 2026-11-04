import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';

class UnblockUserUseCase {
  const UnblockUserUseCase(this._repository);

  final AbstractUserBlocksRepository _repository;

  Future<Either<Failure, Unit>> call({
    required int targetUserId,
    required bool Function() isSessionCurrent,
  }) async {
    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    final result = await _repository.unblockUser(targetUserId: targetUserId);

    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    return result;
  }
}
