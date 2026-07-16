import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/usecases/search_posts_usecase.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_notifier.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_state.dart';

class SearchPostNotifier extends CursorPaginationNotifier<PostListModel> {
  SearchPostNotifier(this._searchPostsUseCase);

  final SearchPostsUseCase _searchPostsUseCase;

  String _keyword = '';

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> fetchPage(
    String? cursor,
  ) {
    return _searchPostsUseCase(keyword: _keyword, cursor: cursor);
  }

  Future<void> search(String keyword) async {
    _keyword = keyword.trim();

    if (_keyword.isEmpty) {
      state = const CursorPaginationState<PostListModel>(
        items: [],
        hasNext: false,
      );
      return;
    }

    await load();
  }

  void clear() {
    _keyword = '';

    state = const CursorPaginationState<PostListModel>(
      items: [],
      hasNext: false,
    );
  }
}
