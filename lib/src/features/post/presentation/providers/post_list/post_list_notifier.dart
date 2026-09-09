import 'package:fpdart/fpdart.dart';
import 'package:logging/logging.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_cache_policy.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_notifier.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_state.dart';

class PostListNotifier extends CursorPaginationNotifier<PostListModel> {
  PostListNotifier(this._repository) {
    load();
  }

  final AbstractPostRepository _repository;
  final _logger = Logger('PostListNotifier');
  bool _didReadCache = false;
  bool _busy = false;
  bool _failedFirstPage = true;
  bool _canCache = false;
  int _requestId = 0;
  List<PostListModel> _freshPosts = [];

  bool _isCurrent(int request) => mounted && request == _requestId;

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> fetchPage(
    String? cursor,
  ) {
    return _repository.getPosts(cursor: cursor);
  }

  @override
  Future<void> load() async {
    if (!mounted || _busy) return;
    _busy = true;
    final request = ++_requestId;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      if (!_didReadCache) {
        _didReadCache = true;
        final cached = await _repository.getCachedPosts();
        if (!_isCurrent(request)) return;
        cached.match((failure) => _logger.warning(failure.errorMessage), (
          posts,
        ) {
          if (posts.isNotEmpty) {
            state = CursorPaginationState<PostListModel>(
              items: posts,
              isLoading: true,
              hasNext: false,
              isFromCache: true,
            );
          }
        });
      }
      final result = await fetchPage(null);
      if (!_isCurrent(request)) return;
      await result.match<Future<void>>(
        (failure) async {
          _failedFirstPage = true;
          _canCache = false;
          _handleFailure(failure);
        },
        (page) async {
          _failedFirstPage = false;
          _canCache = true;
          final unique = {for (final post in page.items) post.postId: post};
          _freshPosts = unique.values.take(kMaxCachedPosts).toList();
          state = CursorPaginationState<PostListModel>(
            items: unique.values.toList(),
            nextCursor: page.nextCursor,
            hasNext: page.hasNext && page.nextCursor != null,
            isLoading: true,
          );
          await _saveCache();
        },
      );
    } finally {
      if (_isCurrent(request)) {
        _busy = false;
        state = state.copyWith(
          isLoading: false,
          errorMessage: state.errorMessage,
        );
      }
    }
  }

  @override
  Future<void> loadMore() async {
    if (!mounted || _busy || _failedFirstPage || state.isFromCache) return;
    final cursor = state.nextCursor;
    if (!state.hasNext || cursor == null) return;
    _busy = true;
    final request = ++_requestId;
    state = state.copyWith(isLoadingMore: true, errorMessage: null);
    try {
      final result = await fetchPage(cursor);
      if (!_isCurrent(request)) return;
      await result.match<Future<void>>(
        (failure) async {
          _handleFailure(failure);
        },
        (page) async {
          final merged = {
            for (final post in state.items) post.postId: post,
            for (final post in page.items) post.postId: post,
          };
          state = CursorPaginationState<PostListModel>(
            items: merged.values.toList(),
            nextCursor: page.nextCursor,
            hasNext:
                page.hasNext &&
                page.nextCursor != null &&
                page.nextCursor != cursor,
            isLoadingMore: true,
          );
          if (_canCache &&
              _freshPosts.length < kMaxCachedPosts &&
              page.items.isNotEmpty) {
            final prefix = {
              for (final post in _freshPosts) post.postId: post,
              for (final post in page.items) post.postId: post,
            };
            _freshPosts = prefix.values.take(kMaxCachedPosts).toList();
            await _saveCache();
          }
        },
      );
    } finally {
      if (_isCurrent(request)) {
        _busy = false;
        state = state.copyWith(
          isLoadingMore: false,
          errorMessage: state.errorMessage,
        );
      }
    }
  }

  Future<void> _saveCache() async {
    final result = await _repository.savePostsCache(
      List.unmodifiable(_freshPosts),
    );
    result.match((failure) => _logger.warning(failure.errorMessage), (_) {});
  }

  void _handleFailure(Failure failure) {
    // 인증 거부 시 캐시를 대신 보여주어 접근 권한을 우회하지 않음.
    if (failure is ServerFailure &&
        (failure.statusCode == 401 || failure.statusCode == 403)) {
      _canCache = false;
      _freshPosts = [];
      state = CursorPaginationState<PostListModel>(
        hasNext: false,
        errorMessage: failure.errorMessage,
      );
      return;
    }
    state = state.copyWith(
      errorMessage: failure.errorMessage,
      isOffline: failure is NetworkFailure,
    );
  }

  Future<void> retry() =>
      _failedFirstPage || state.isFromCache ? load() : loadMore();

  void _invalidatePending() {
    _requestId++;
    _busy = false;
    _canCache = false;
    _freshPosts = [];
  }

  void removePost(int postId) {
    if (!mounted) return;
    _invalidatePending();
    state = state.copyWith(
      items: state.items.where((post) => post.postId != postId).toList(),
      isLoading: false,
      isLoadingMore: false,
    );
  }

  void updateTitle(int postId, String title) {
    if (!mounted) return;
    _invalidatePending();
    state = state.copyWith(
      items: state.items
          .map(
            (post) =>
                post.postId == postId ? post.copyWith(title: title) : post,
          )
          .toList(),
      isLoading: false,
      isLoadingMore: false,
    );
  }

  void updatePost(PostListModel updatedPost) {
    if (!mounted) return;
    _invalidatePending();
    state = state.copyWith(
      items: state.items
          .map((post) => post.postId == updatedPost.postId ? updatedPost : post)
          .toList(),
      isLoading: false,
      isLoadingMore: false,
    );
  }
}
