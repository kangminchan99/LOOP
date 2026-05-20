import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/post/domain/models/create_post_request_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/features/post/presentation/providers/create_post/create_post_state.dart';

class CreatePostStateNotifier extends StateNotifier<CreatePostState> {
  final AbstractPostRepository _postRepository;

  CreatePostStateNotifier(this._postRepository)
    : super(const CreatePostState.initial());

  Future<void> submitPost({
    required String title,
    required String content,
  }) async {
    state = const CreatePostState.loading();

    final result = await _postRepository.createPost(
      CreatePostRequestModel(title: title, content: content),
    );

    state = result.match(
      (failure) => CreatePostState.error(failure.errorMessage),
      (post) => CreatePostState.success(post),
    );
  }
}
