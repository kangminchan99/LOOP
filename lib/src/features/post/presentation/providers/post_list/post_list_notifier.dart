import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_notifier.dart';

class PostListNotifier
    extends CursorPaginationNotifier<PostListModel> {
  final AbstractPostRepository _repository;
  PostListNotifier(this._repository);

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> fetchPage(
    int? cursor,
  ) {
    return _repository.getPosts(cursor: cursor);
  }
}