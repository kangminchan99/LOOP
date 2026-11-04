import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/models/user_block_model.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';

class BlockUserUseCase {
  const BlockUserUseCase(this._repository);

  final AbstractUserBlocksRepository _repository;

  Future<Either<Failure, UserBlockModel>> call({
    required int targetUserId,
    required bool Function() isSessionCurrent,
  }) async {
    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    final result = await _repository.blockUser(targetUserId: targetUserId);

    if (!isSessionCurrent()) {
      return const Left(CancelTokenFailure('로그인 세션이 변경되었습니다.', null));
    }

    return result;
  }
}
