import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_block_model.freezed.dart';
part 'user_block_model.g.dart';

@freezed
abstract class UserBlockModel with _$UserBlockModel {
  const factory UserBlockModel({
    // 차단한 대상 사용자 ID
    required int blockedUserId,

    // 서버에 저장된 차단 시각
    required DateTime blockedAt,
  }) = _UserBlockModel;

  factory UserBlockModel.fromJson(Map<String, dynamic> json) =>
      _$UserBlockModelFromJson(json);
}
