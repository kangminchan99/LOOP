import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_post_response_model.freezed.dart';
part 'create_post_response_model.g.dart';

@freezed
abstract class CreatePostResponseModel with _$CreatePostResponseModel {
  const factory CreatePostResponseModel({
    required int id,
    required String title,
    required String content,
    required int authorId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CreatePostResponseModel;

  factory CreatePostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CreatePostResponseModelFromJson(json);
}
