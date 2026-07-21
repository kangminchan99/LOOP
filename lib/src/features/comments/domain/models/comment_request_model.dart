import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_request_model.freezed.dart';
part 'comment_request_model.g.dart';

@freezed
abstract class CommentRequestModel with _$CommentRequestModel {
  const factory CommentRequestModel({required String content}) =
      _CommentRequestModel;

  factory CommentRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CommentRequestModelFromJson(json);
}
