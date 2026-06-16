import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_request_model.freezed.dart';
part 'post_request_model.g.dart';

@freezed
abstract class PostRequestModel with _$PostRequestModel {
  const factory PostRequestModel({
    required String title,
    required String content,
  }) = _PostRequestModel;

  factory PostRequestModel.fromJson(Map<String, dynamic> json) =>
      _$PostRequestModelFromJson(json);
}
