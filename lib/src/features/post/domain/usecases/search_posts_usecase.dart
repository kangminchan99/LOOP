import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class SearchPostsUseCase {
  const SearchPostsUseCase(this._repository);

  final AbstractPostRepository _repository;

  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> call({
    required String keyword,
    String? cursor,
  }) {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      return Future.value(const Left(ServerFailure('검색어를 입력해주세요.', null)));
    }

    return _repository.searchPosts(keyword: trimmedKeyword, cursor: cursor);
  }
}
