import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_response_model.freezed.dart';
part 'post_response_model.g.dart';

@freezed
abstract class PostResponseModel with _$PostResponseModel {
  const factory PostResponseModel({
    required int id,
    required String title,
    required String content,
    required int authorId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PostResponseModel;

  factory PostResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PostResponseModelFromJson(json);
}
