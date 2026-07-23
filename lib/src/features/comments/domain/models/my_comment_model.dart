import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_comment_model.freezed.dart';
part 'my_comment_model.g.dart';

@freezed
abstract class MyCommentModel with _$MyCommentModel {
  const factory MyCommentModel({
    required int id,
    required int postId,
    required String postTitle,
    required String content,
    required DateTime createdAt,
  }) = _MyCommentModel;

  factory MyCommentModel.fromJson(Map<String, dynamic> json) =>
      _$MyCommentModelFromJson(json);
}
