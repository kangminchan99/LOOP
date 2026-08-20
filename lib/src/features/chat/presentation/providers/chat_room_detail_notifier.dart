import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:loop/src/features/chat/domain/usecases/chat_usecase.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_detail_state.dart';

class ChatRoomDetailNotifier extends StateNotifier<ChatRoomDetailState> {
  ChatRoomDetailNotifier({
    required int roomId,
    required ChatUseCase chatUseCase,
  }) : _roomId = roomId,
       _chatUseCase = chatUseCase,
       super(const ChatRoomDetailState());

  final int _roomId;
  final ChatUseCase _chatUseCase;
  StreamSubscription<ChatMessageModel>? _messageSubscription;

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final messagesResult = await _chatUseCase.getMessages(roomId: _roomId);

    messagesResult.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.errorMessage,
        );
      },
      (messages) {
        state = state.copyWith(isLoading: false, messages: messages);
      },
    );

    await _connectSocket();
  }

  Future<void> _connectSocket() async {
    final connectResult = await _chatUseCase.connectSocket();

    connectResult.match(
      (failure) {
        state = state.copyWith(
          isSocketConnected: false,
          errorMessage: failure.errorMessage,
        );
      },
      (_) {
        state = state.copyWith(isSocketConnected: true);

        _chatUseCase.joinRoom(roomId: _roomId).match((failure) {
          state = state.copyWith(errorMessage: failure.errorMessage);
        }, (_) {});

        _messageSubscription ??= _chatUseCase.watchMessages().listen((message) {
          if (message.roomId != _roomId) {
            return;
          }

          final alreadyExists = state.messages.any(
            (item) => item.id == message.id,
          );

          if (alreadyExists) {
            return;
          }

          state = state.copyWith(messages: [...state.messages, message]);
        });
      },
    );
  }

  void sendMessage(String content) {
    final trimmedContent = content.trim();

    if (trimmedContent.isEmpty) {
      return;
    }

    _chatUseCase.sendMessage(roomId: _roomId, content: trimmedContent).match((
      failure,
    ) {
      state = state.copyWith(errorMessage: failure.errorMessage);
    }, (_) {});
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _chatUseCase.disconnectSocket();
    super.dispose();
  }
}
