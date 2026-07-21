import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/models/comment_request_model.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

abstract interface class AbstractCommentRepository {
  Future<Either<Failure, CursorPaginatedResponse<CommentModel>>> getComments({
    required int postId,
    String? cursor,
  });

  Future<Either<Failure, CommentModel>> createComment({
    required int postId,
    required CommentRequestModel request,
  });

  Future<Either<Failure, void>> deleteComment({
    required int postId,
    required int commentId,
  });
}
