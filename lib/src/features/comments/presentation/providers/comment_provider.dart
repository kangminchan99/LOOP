import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/comments/data/data_sources/remote/comment_api.dart';
import 'package:loop/src/features/comments/data/repositories/comment_repository_impl.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/models/my_comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/features/comments/domain/usecases/create_comment_usecase.dart';
import 'package:loop/src/features/comments/domain/usecases/delete_comment_usecase.dart';
import 'package:loop/src/features/comments/domain/usecases/get_comment_usecase.dart';
import 'package:loop/src/features/comments/domain/usecases/get_my_comments_usecase.dart';
import 'package:loop/src/features/comments/presentation/providers/comment_list_notifier.dart';
import 'package:loop/src/features/comments/presentation/providers/my_comment_notifier.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_state.dart';

final commentApiProvider = Provider<CommentApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CommentApi(dio);
});

final commentRepositoryProvider = Provider<AbstractCommentRepository>((ref) {
  final api = ref.watch(commentApiProvider);
  return CommentRepositoryImpl(api);
});

final getCommentsUseCaseProvider = Provider<GetCommentsUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return GetCommentsUseCase(repository);
});

final createCommentUseCaseProvider = Provider<CreateCommentUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return CreateCommentUseCase(repository);
});

final deleteCommentUseCaseProvider = Provider<DeleteCommentUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return DeleteCommentUseCase(repository);
});

final commentListProvider =
    StateNotifierProvider.family<
      CommentListNotifier,
      CursorPaginationState<CommentModel>,
      int
    >((ref, postId) {
      return CommentListNotifier(
        postId: postId,
        getCommentsUseCase: ref.watch(getCommentsUseCaseProvider),
        createCommentUseCase: ref.watch(createCommentUseCaseProvider),
        deleteCommentUseCase: ref.watch(deleteCommentUseCaseProvider),
        analyticsService: ref.watch(analyticsServiceProvider),
      );
    });

final getMyCommentsUseCaseProvider = Provider<GetMyCommentsUseCase>((ref) {
  final repository = ref.watch(commentRepositoryProvider);
  return GetMyCommentsUseCase(repository);
});

final myCommentsProvider =
    StateNotifierProvider<
      MyCommentsNotifier,
      CursorPaginationState<MyCommentModel>
    >((ref) {
      final getMyCommentsUseCase = ref.watch(getMyCommentsUseCaseProvider);

      return MyCommentsNotifier(getMyCommentsUseCase: getMyCommentsUseCase);
    });
