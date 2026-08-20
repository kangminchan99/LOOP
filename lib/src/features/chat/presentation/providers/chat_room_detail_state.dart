import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';

class ChatRoomDetailState {
  const ChatRoomDetailState({
    this.isLoading = false,
    this.isSocketConnected = false,
    this.messages = const [],
    this.errorMessage,
  });

  final bool isLoading;
  final bool isSocketConnected;
  final List<ChatMessageModel> messages;
  final String? errorMessage;

  ChatRoomDetailState copyWith({
    bool? isLoading,
    bool? isSocketConnected,
    List<ChatMessageModel>? messages,
    String? errorMessage,
  }) {
    return ChatRoomDetailState(
      isLoading: isLoading ?? this.isLoading,
      isSocketConnected: isSocketConnected ?? this.isSocketConnected,
      messages: messages ?? this.messages,
      errorMessage: errorMessage,
    );
  }
}
