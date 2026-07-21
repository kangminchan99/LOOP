import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class GetCommentsUseCase {
  final AbstractCommentRepository _repository;

  GetCommentsUseCase(this._repository);

  Future<Either<Failure, CursorPaginatedResponse<CommentModel>>> call({
    required int postId,
    String? cursor,
  }) {
    return _repository.getComments(postId: postId, cursor: cursor);
  }
}
