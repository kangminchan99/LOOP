import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_list_model.freezed.dart';
part 'post_list_model.g.dart';

@freezed
abstract class PostListModel with _$PostListModel {
  const factory PostListModel({
    required int postId,
    required String title,
    required String authorNickname,
    required DateTime createdAt,
  }) = _PostListModel;

  factory PostListModel.fromJson(Map<String, dynamic> json) =>
      _$PostListModelFromJson(json);
}
