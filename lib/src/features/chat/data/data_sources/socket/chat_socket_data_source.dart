import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatSocketDataSource {
  ChatSocketDataSource({required FlutterSecureStorage secureStorage})
    : _secureStorage = secureStorage;

  final FlutterSecureStorage _secureStorage;
  final StreamController<ChatMessageModel> _messageController =
      StreamController<ChatMessageModel>.broadcast();

  io.Socket? _socket;

  Stream<ChatMessageModel> watchMessages() {
    return _messageController.stream;
  }

  Future<void> connect() async {
    if (_socket?.connected ?? false) {
      return;
    }

    final accessToken = await _secureStorage.read(key: kAccessTokenKey);

    if (accessToken == null) {
      throw Exception('AccessToken이 없습니다.');
    }

    final socket = io.io(
      apiUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': accessToken})
          .disableAutoConnect()
          .build(),
    );

    socket.on('chat:message', (data) {
      if (data is Map<String, dynamic>) {
        _messageController.add(ChatMessageModel.fromJson(data));
        return;
      }

      if (data is Map) {
        _messageController.add(
          ChatMessageModel.fromJson(Map<String, dynamic>.from(data)),
        );
      }
    });

    socket.connect();
    _socket = socket;
  }

  void joinRoom({required int roomId}) {
    _socket?.emit('chat:join', {'roomId': roomId});
  }

  void sendMessage({required int roomId, required String content}) {
    _socket?.emit('chat:send', {'roomId': roomId, 'content': content});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }

  void dispose() {
    disconnect();
    _messageController.close();
  }
}
