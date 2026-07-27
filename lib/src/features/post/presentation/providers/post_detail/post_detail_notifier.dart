import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/analytics/analytics_service.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';

class PostDetailNotifier extends StateNotifier<PostDetailState> {
  final AbstractPostRepository _repository;
  final int _postId;
  final AnalyticsService _analyticsService;
  PostDetailNotifier(this._repository, this._postId, this._analyticsService)
    : super(const PostDetailState.initial()) {
    load();
  }

  Future<void> load() async {
    state = const PostDetailState.loading();

    final result = await _repository.getPostById(_postId);

    await result.match(
      (failure) async {
        state = PostDetailState.error(failure.errorMessage);
      },
      (post) async {
        state = PostDetailState.success(post);
        await _analyticsService.logPostView(postId: post.id);
      },
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

  Future<void> update(PostRequestModel request) async {
    final current = state;
    if (current is! PostDetailSuccess) return;

    final result = await _repository.updatePost(_postId, request);

    state = result.fold(
      (failure) => PostDetailState.error(failure.errorMessage),
      (updatedPost) => PostDetailState.success(updatedPost),
    );
  }
}
