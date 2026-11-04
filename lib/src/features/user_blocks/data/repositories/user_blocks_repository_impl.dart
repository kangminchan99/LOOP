import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/data/data_sources/remote/user_blocks_api.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_list_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/user_block_model.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';

class UserBlocksRepositoryImpl implements AbstractUserBlocksRepository {
  const UserBlocksRepositoryImpl(this._api);

  final UserBlocksApi _api;

  @override
  Future<Either<Failure, UserBlockModel>> blockUser({
    required int targetUserId,
  }) {
    return _run(() async {
      final response = await _api.blockUser(targetUserId: targetUserId);
      return UserBlockModel.fromJson(_requireData(response.data));
    });
  }

  @override
  Future<Either<Failure, Unit>> unblockUser({required int targetUserId}) {
    return _run(() async {
      await _api.unblockUser(targetUserId: targetUserId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, BlockedUserListModel>> getBlockedUsers({
    int limit = 20,
    String? cursor,
  }) {
    return _run(() async {
      final response = await _api.getBlockedUsers(limit: limit, cursor: cursor);
      return BlockedUserListModel.fromJson(_requireData(response.data));
    });
  }

  Map<String, dynamic> _requireData(Map<String, dynamic>? data) {
    if (data == null) {
      throw const FormatException('응답 데이터가 없습니다.');
    }
    return data;
  }

  // 세 메서드에서 공통으로 성공·실패를 변환한다.
  Future<Either<Failure, T>> _run<T>(Future<T> Function() action) async {
    try {
      return Right(await action());
    } on DioException catch (error) {
      final message = extractDioErrorMessage(error);
      final statusCode = error.response?.statusCode;

      switch (error.type) {
        case DioExceptionType.cancel:
          return Left(CancelTokenFailure(message, statusCode));
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return Left(NetworkFailure(message));
        default:
          return Left(ServerFailure(message, statusCode));
      }
    } on FormatException {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    }
  }
}
