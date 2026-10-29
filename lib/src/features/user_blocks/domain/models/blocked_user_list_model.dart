import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_model.dart';

part 'blocked_user_list_model.freezed.dart';
part 'blocked_user_list_model.g.dart';

@freezed
abstract class BlockedUserListModel with _$BlockedUserListModel {
  const factory BlockedUserListModel({
    // 현재 페이지의 차단 사용자 목록
    required List<BlockedUserModel> items,

    // 다음 조회에 전달할 커서. 마지막 페이지면 null
    required String? nextCursor,

    // 추가로 조회할 페이지가 있는지
    required bool hasNext,
  }) = _BlockedUserListModel;

  factory BlockedUserListModel.fromJson(Map<String, dynamic> json) =>
      _$BlockedUserListModelFromJson(json);
}
