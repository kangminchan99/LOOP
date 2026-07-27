import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/analytics/analytics_service.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/usecases/create_comment_usecase.dart';
import 'package:loop/src/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:loop/src/features/comments/domain/usecases/get_comment_usecase.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_notifier.dart';

class CommentListNotifier extends CursorPaginationNotifier<CommentModel> {
  final int postId;
  final GetCommentsUseCase _getCommentsUseCase;
  final CreateCommentUseCase _createCommentUseCase;
  final DeleteCommentUseCase _deleteCommentUseCase;
  final AnalyticsService _analyticsService;

  CommentListNotifier({
    required this.postId,
    required GetCommentsUseCase getCommentsUseCase,
    required CreateCommentUseCase createCommentUseCase,
    required DeleteCommentUseCase deleteCommentUseCase,
    required AnalyticsService analyticsService,
  }) : _getCommentsUseCase = getCommentsUseCase,
       _createCommentUseCase = createCommentUseCase,
       _deleteCommentUseCase = deleteCommentUseCase,
       _analyticsService = analyticsService {
    load();
  }

  @override
  Future<Either<Failure, CursorPaginatedResponse<CommentModel>>> fetchPage(
    String? cursor,
  ) {
    return _getCommentsUseCase(postId: postId, cursor: cursor);
  }

  Future<Either<Failure, CommentModel>> create(String content) async {
    final result = await _createCommentUseCase(
      postId: postId,
      content: content,
    );

    await result.match((_) async {}, (comment) async {
      state = state.copyWith(items: [comment, ...state.items]);
      await _analyticsService.logCommentCreate(postId: postId);
    });

    return result;
  }

  Future<Either<Failure, void>> delete(int commentId) async {
    final result = await _deleteCommentUseCase(
      postId: postId,
      commentId: commentId,
    );

    result.match((_) {}, (_) {
      state = state.copyWith(
        items: state.items.where((comment) => comment.id != commentId).toList(),
      );
    });

    return result;
  }
}
