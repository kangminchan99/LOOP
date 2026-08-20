import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';

class ChatRoomListState {
  const ChatRoomListState({
    this.isLoading = false,
    this.rooms = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final List<ChatRoomModel> rooms;
  final String? errorMessage;

  ChatRoomListState copyWith({
    bool? isLoading,
    List<ChatRoomModel>? rooms,
    String? errorMessage,
  }) {
    return ChatRoomListState(
      isLoading: isLoading ?? this.isLoading,
      rooms: rooms ?? this.rooms,
      errorMessage: errorMessage,
    );
  }
}
