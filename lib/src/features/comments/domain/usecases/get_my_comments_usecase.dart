import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/my_comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class GetMyCommentsUseCase {
  final AbstractCommentRepository _repository;

  GetMyCommentsUseCase(this._repository);

  Future<Either<Failure, CursorPaginatedResponse<MyCommentModel>>> call({
    String? cursor,
  }) {
    return _repository.getMyComments(cursor: cursor);
  }
}
