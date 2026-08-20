import 'package:flutter/material.dart';
import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';

class ChatRoomTile extends StatelessWidget {
  const ChatRoomTile({super.key, required this.room, required this.onTap});

  final ChatRoomModel room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = room.participants.map((item) => item.nickname).join(', ');

    return ListTile(
      onTap: onTap,
      title: Text(title.isEmpty ? '채팅방 ${room.id}' : title),
      subtitle: Text(room.lastMessage ?? '아직 메시지가 없습니다.'),
      trailing:
          room.unreadCount > 0
              ? Badge(
                label: Text('${room.unreadCount}'),
                backgroundColor: theme.colorScheme.primary,
              )
              : null,
    );
  }
}
