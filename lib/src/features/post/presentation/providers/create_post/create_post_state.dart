import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';

part 'create_post_state.freezed.dart';

@freezed
sealed class CreatePostState with _$CreatePostState {
  const factory CreatePostState.initial() = CreatePostInitial;
  const factory CreatePostState.loading() = CreatePostLoading;
  const factory CreatePostState.success(PostDetailModel post) =
      CreatePostSuccess;
  const factory CreatePostState.error(String message) = CreatePostError;
}
