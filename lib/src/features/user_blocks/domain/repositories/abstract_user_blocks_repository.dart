import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_list_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/user_block_model.dart';

abstract interface class AbstractUserBlocksRepository {
  Future<Either<Failure, UserBlockModel>> blockUser({
    required int targetUserId,
  });

  Future<Either<Failure, Unit>> unblockUser({required int targetUserId});

  Future<Either<Failure, BlockedUserListModel>> getBlockedUsers({
    int limit = 20,
    String? cursor,
  });
}
