import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_detail_model.freezed.dart';
part 'post_detail_model.g.dart';

@freezed
abstract class PostDetailModel with _$PostDetailModel {
  const factory PostDetailModel({
    required int id,
    required String title,
    required String content,
    required int authorId,
    required DateTime updatedAt,
    String? summary,
    @Default('PENDING') String summaryStatus,
    String? summaryError,
    DateTime? summaryGeneratedAt,
    @Default(false) bool isMine,
  }) = _PostDetailModel;

  factory PostDetailModel.fromJson(Map<String, dynamic> json) =>
      _$PostDetailModelFromJson(json);
}
