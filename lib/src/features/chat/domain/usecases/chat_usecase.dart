import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';
import 'package:loop/src/features/chat/domain/repositories/abstract_chat_repository.dart';

class ChatUseCase {
  const ChatUseCase(this._repository);

  final AbstractChatRepository _repository;

  Future<Either<Failure, ChatRoomModel>> createDirectRoom({
    required int targetUserId,
  }) {
    return _repository.createDirectRoom(targetUserId: targetUserId);
  }

  Future<Either<Failure, List<ChatRoomModel>>> getMyRooms() {
    return _repository.getMyRooms();
  }

  Future<Either<Failure, List<ChatMessageModel>>> getMessages({
    required int roomId,
    int limit = 30,
    int? cursorId,
  }) {
    return _repository.getMessages(
      roomId: roomId,
      limit: limit,
      cursorId: cursorId,
    );
  }

  Future<Either<Failure, void>> connectSocket() {
    return _repository.connectSocket();
  }

  Either<Failure, void> joinRoom({required int roomId}) {
    return _repository.joinRoom(roomId: roomId);
  }

  Either<Failure, void> sendMessage({
    required int roomId,
    required String content,
  }) {
    return _repository.sendMessage(roomId: roomId, content: content);
  }

  Stream<ChatMessageModel> watchMessages() {
    return _repository.watchMessages();
  }

  void disconnectSocket() {
    _repository.disconnectSocket();
  }
}
