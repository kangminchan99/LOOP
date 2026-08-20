import 'package:dio/dio.dart';
import 'package:loop/src/core/network/dio_network.dart';
import 'package:loop/src/features/chat/domain/models/chat_message_model.dart';
import 'package:loop/src/features/chat/domain/models/chat_room_model.dart';

class ChatRemoteDataSource {
  ChatRemoteDataSource({Dio? dio}) : _dio = dio ?? DioNetwork.appAPI;

  final Dio _dio;

  Future<ChatRoomModel> createDirectRoom({required int targetUserId}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/chat/rooms',
      data: {'targetUserId': targetUserId},
    );

    return ChatRoomModel.fromJson(response.data!);
  }

  Future<List<ChatRoomModel>> getMyRooms() async {
    final response = await _dio.get<List<dynamic>>('/chat/rooms');

    return response.data!
        .map((json) => ChatRoomModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ChatMessageModel>> getMessages({
    required int roomId,
    int limit = 30,
    int? cursorId,
  }) async {
    final response = await _dio.get<List<dynamic>>(
      '/chat/rooms/$roomId/messages',
      queryParameters: {
        'limit': limit,
        if (cursorId != null) 'cursorId': cursorId,
      },
    );

    return response.data!
        .map((json) => ChatMessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
