import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/my_comment_model.dart';
import 'package:loop/src/features/comments/domain/usecases/get_my_comments_usecase.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_notifier.dart';

class MyCommentsNotifier extends CursorPaginationNotifier<MyCommentModel> {
  final GetMyCommentsUseCase _getMyCommentsUseCase;

  MyCommentsNotifier({required GetMyCommentsUseCase getMyCommentsUseCase})
    : _getMyCommentsUseCase = getMyCommentsUseCase {
    load();
  }

  @override
  Future<Either<Failure, CursorPaginatedResponse<MyCommentModel>>> fetchPage(
    String? cursor,
  ) {
    return _getMyCommentsUseCase(cursor: cursor);
  }
}
