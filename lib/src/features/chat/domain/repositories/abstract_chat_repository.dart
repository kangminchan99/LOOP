import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';

abstract interface class AbstractChatRepository {
  Future<Either<Failure, ChatRoomModel>> createDirectRoom({
    required int targetUserId,
  });

  Future<Either<Failure, List<ChatRoomModel>>> getMyRooms();

  Future<Either<Failure, List<ChatMessageModel>>> getMessages({
    required int roomId,
    int limit,
    int? cursorId,
  });

  Future<Either<Failure, void>> connectSocket();

  Either<Failure, void> joinRoom({required int roomId});

  Either<Failure, void> sendMessage({
    required int roomId,
    required String content,
  });

  Stream<ChatMessageModel> watchMessages();

  void disconnectSocket();
}
