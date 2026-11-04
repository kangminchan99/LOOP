import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_list_model.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';

class GetBlockedUsersUseCase {
  const GetBlockedUsersUseCase(this._repository);

  final AbstractUserBlocksRepository _repository;

  Future<Either<Failure, BlockedUserListModel>> call({
    int limit = 20,
    String? cursor,
  }) {
    return _repository.getBlockedUsers(limit: limit, cursor: cursor);
  }
}
