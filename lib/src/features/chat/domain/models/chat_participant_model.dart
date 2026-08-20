import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_participant_model.freezed.dart';
part 'chat_participant_model.g.dart';

@freezed
abstract class ChatParticipantModel with _$ChatParticipantModel {
  const factory ChatParticipantModel({
    required int userId,
    required String nickname,
    String? profileImageUrl,
  }) = _ChatParticipantModel;

  factory ChatParticipantModel.fromJson(Map<String, dynamic> json) =>
      _$ChatParticipantModelFromJson(json);
}
