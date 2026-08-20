import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/chat/data/data_sources/remote/chat_remote_data_source.dart';
import 'package:loop/src/features/chat/data/data_sources/socket/chat_socket_data_source.dart';
import 'package:loop/src/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:loop/src/features/chat/domain/repositories/abstract_chat_repository.dart';
import 'package:loop/src/features/chat/domain/usecases/chat_usecase.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_detail_notifier.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_detail_state.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_list_notifier.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_room_list_state.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  return ChatRemoteDataSource(dio: ref.watch(dioProvider));
});

final chatSocketDataSourceProvider = Provider<ChatSocketDataSource>((ref) {
  final dataSource = ChatSocketDataSource(
    secureStorage: ref.watch(secureStorageProvider),
  );

  ref.onDispose(dataSource.dispose);

  return dataSource;
});

final chatRepositoryProvider = Provider<AbstractChatRepository>((ref) {
  return ChatRepositoryImpl(
    remoteDataSource: ref.watch(chatRemoteDataSourceProvider),
    socketDataSource: ref.watch(chatSocketDataSourceProvider),
  );
});

final chatUseCaseProvider = Provider<ChatUseCase>((ref) {
  return ChatUseCase(ref.watch(chatRepositoryProvider));
});

final chatRoomListProvider =
    StateNotifierProvider<ChatRoomListNotifier, ChatRoomListState>((ref) {
      return ChatRoomListNotifier(ref.watch(chatUseCaseProvider));
    });

final chatRoomDetailProvider = StateNotifierProvider.family<
  ChatRoomDetailNotifier,
  ChatRoomDetailState,
  int
>((ref, roomId) {
  return ChatRoomDetailNotifier(
    roomId: roomId,
    chatUseCase: ref.watch(chatUseCaseProvider),
  );
});
