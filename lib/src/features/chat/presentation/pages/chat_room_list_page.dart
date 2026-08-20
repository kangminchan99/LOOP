import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_providers.dart';
import 'package:loop/src/features/chat/presentation/widgets/chat_room_tile.dart';

class ChatRoomListPage extends ConsumerStatefulWidget {
  const ChatRoomListPage({super.key});

  @override
  ConsumerState<ChatRoomListPage> createState() => _ChatRoomListPageState();
}

class _ChatRoomListPageState extends ConsumerState<ChatRoomListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatRoomListProvider.notifier).loadRooms();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomListProvider);

    return DefaultLayout(
      appBarTitle: '채팅',
      child: RefreshIndicator(
        onRefresh: () => ref.read(chatRoomListProvider.notifier).loadRooms(),
        child: Builder(
          builder: (context) {
            if (state.isLoading && state.rooms.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.errorMessage != null && state.rooms.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            if (state.rooms.isEmpty) {
              return const Center(child: Text('채팅방이 없습니다.'));
            }

            return ListView.separated(
              itemCount: state.rooms.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final room = state.rooms[index];

                return ChatRoomTile(
                  room: room,
                  onTap: () async {
                    await context.push(
                      AppRoute.chatRoomDetail.path.replaceFirst(
                        ':roomId',
                        '${room.id}',
                      ),
                    );

                    if (!context.mounted) return;

                    await ref.read(chatRoomListProvider.notifier).loadRooms();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
