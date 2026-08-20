import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/chat/domain/models/chat_participant_model.dart';

part 'chat_room_model.freezed.dart';
part 'chat_room_model.g.dart';

@freezed
abstract class ChatRoomModel with _$ChatRoomModel {
  const factory ChatRoomModel({
    required int id,
    required String type,
    required List<ChatParticipantModel> participants,
    String? lastMessage,
    required int unreadCount,
    required DateTime createdAt,
  }) = _ChatRoomModel;

  factory ChatRoomModel.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomModelFromJson(json);
}
