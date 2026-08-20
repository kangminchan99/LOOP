import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/chat/domain/usecases/chat_usecase.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_list_state.dart';

class ChatRoomListNotifier extends StateNotifier<ChatRoomListState> {
  ChatRoomListNotifier(this._chatUseCase) : super(const ChatRoomListState());

  final ChatUseCase _chatUseCase;

  Future<void> loadRooms() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _chatUseCase.getMyRooms();

    result.match(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.errorMessage,
        );
      },
      (rooms) {
        state = state.copyWith(isLoading: false, rooms: rooms);
      },
    );
  }
}
