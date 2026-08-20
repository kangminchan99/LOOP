import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/chat/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:loop/src/features/chat/data/data_sources/socket/chat_socket_data_source.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';
import 'package:loop/src/features/chat/domain/repositories/abstract_chat_repository.dart';

class ChatRepositoryImpl implements AbstractChatRepository {
  const ChatRepositoryImpl({
    required ChatRemoteDataSource remoteDataSource,
    required ChatSocketDataSource socketDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _socketDataSource = socketDataSource;

  final ChatRemoteDataSource _remoteDataSource;
  final ChatSocketDataSource _socketDataSource;

  @override
  Future<Either<Failure, ChatRoomModel>> createDirectRoom({
    required int targetUserId,
  }) async {
    try {
      final room = await _remoteDataSource.createDirectRoom(
        targetUserId: targetUserId,
      );
      return Right(room);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, List<ChatRoomModel>>> getMyRooms() async {
    try {
      final rooms = await _remoteDataSource.getMyRooms();
      return Right(rooms);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, List<ChatMessageModel>>> getMessages({
    required int roomId,
    int limit = 30,
    int? cursorId,
  }) async {
    try {
      final messages = await _remoteDataSource.getMessages(
        roomId: roomId,
        limit: limit,
        cursorId: cursorId,
      );
      return Right(messages);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, void>> connectSocket() async {
    try {
      await _socketDataSource.connect();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Either<Failure, void> joinRoom({required int roomId}) {
    try {
      _socketDataSource.joinRoom(roomId: roomId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Either<Failure, void> sendMessage({
    required int roomId,
    required String content,
  }) {
    try {
      _socketDataSource.sendMessage(roomId: roomId, content: content);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Stream<ChatMessageModel> watchMessages() {
    return _socketDataSource.watchMessages();
  }

  @override
  void disconnectSocket() {
    _socketDataSource.disconnect();
  }
}
