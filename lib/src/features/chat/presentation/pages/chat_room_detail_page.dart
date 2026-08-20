import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_providers.dart';
import 'package:loop/src/features/chat/presentation/widgets/chat_message_bubble.dart';

class ChatRoomDetailPage extends ConsumerStatefulWidget {
  const ChatRoomDetailPage({super.key, required this.roomId});

  final int roomId;

  @override
  ConsumerState<ChatRoomDetailPage> createState() => _ChatRoomDetailPageState();
}

class _ChatRoomDetailPageState extends ConsumerState<ChatRoomDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(chatRoomDetailProvider(widget.roomId).notifier).initialize();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatRoomDetailProvider(widget.roomId));
    final notifier = ref.read(chatRoomDetailProvider(widget.roomId).notifier);
    final loginState = ref.watch(loginProvider);
    final myUserId = loginState is LoginSuccess ? loginState.user.id : null;

    return DefaultLayout(
      appBarTitle: '채팅방',
      child: Column(
        children: [
          if (state.errorMessage != null)
            MaterialBanner(
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                  },
                  child: const Text('닫기'),
                ),
              ],
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];

                      return ChatMessageBubble(
                        message: message,
                        isMine: message.senderId == myUserId,
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: '메시지를 입력하세요',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () {
                      notifier.sendMessage(_messageController.text);
                      _messageController.clear();
                    },
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
