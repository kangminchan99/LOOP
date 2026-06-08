import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';

part 'post_detail_state.freezed.dart';

@freezed
sealed class PostDetailState with _$PostDetailState {
  const factory PostDetailState.initial() = PostDetailInitial;
  const factory PostDetailState.loading() = PostDetailLoading;
  const factory PostDetailState.success(PostDetailModel post) =
      PostDetailSuccess;
  const factory PostDetailState.deleting(PostDetailModel post) =
      PostDetailDeleting;
  const factory PostDetailState.deleted() = PostDetailDeleted;
  const factory PostDetailState.error(String message) = PostDetailError;
}
