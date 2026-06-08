import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';

class PostDetailNotifier extends StateNotifier<PostDetailState> {
  PostDetailNotifier(this._repository, this._postId)
    : super(const PostDetailState.initial()) {
    load();
  }

  final AbstractPostRepository _repository;
  final int _postId;

  Future<void> load() async {
    state = const PostDetailState.loading();
    final result = await _repository.getPostById(_postId);
    state = result.fold(
      (failure) => PostDetailState.error(failure.errorMessage),
      (post) => PostDetailState.success(post),
    );
  }

  Future<void> delete() async {
    final current = state;
    if (current is! PostDetailSuccess) return;

    state = PostDetailState.deleting(current.post);
    final result = await _repository.deletePost(_postId);
    state = result.fold(
      (failure) => PostDetailState.error(failure.errorMessage),
      (_) => const PostDetailState.deleted(),
    );
  }
}
