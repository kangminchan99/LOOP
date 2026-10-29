import 'package:freezed_annotation/freezed_annotation.dart';

part 'blocked_user_model.freezed.dart';
part 'blocked_user_model.g.dart';

@freezed
abstract class BlockedUserModel with _$BlockedUserModel {
  const factory BlockedUserModel({
    // 차단 관계 자체의 ID
    required int blockId,

    // 차단 대상 계정 ID: 해제 요청에 사용
    required int userId,

    // 프로필 정보는 서버에서 null을 허용한다.
    required String? nickname,
    required String? profileImageUrl,

    required DateTime blockedAt,
  }) = _BlockedUserModel;

  factory BlockedUserModel.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserModelFromJson(json);
}
