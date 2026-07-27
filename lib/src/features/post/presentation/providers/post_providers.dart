import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/post/data/data_sources/remote/post_api.dart';
import 'package:loop/src/features/post/data/repositories/post_repository_impl.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/features/post/domain/usecases/search_posts_usecase.dart';
import 'package:loop/src/features/post/presentation/providers/create_post/create_post_state.dart';
import 'package:loop/src/features/post/presentation/providers/create_post/create_post_state_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_list/post_list_notifier.dart';
import 'package:loop/src/features/post/presentation/providers/search_post/search_post_notifier.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_state.dart';

final postApiProvider = Provider<PostApi>((ref) {
  final dio = ref.watch(dioProvider);
  return PostApi(dio);
});

final createPostRepositoryProvider = Provider<AbstractPostRepository>((ref) {
  final api = ref.watch(postApiProvider);
  return PostRepositoryImpl(api);
});

final createPostProvider =
    StateNotifierProvider<CreatePostStateNotifier, CreatePostState>((ref) {
      final repository = ref.watch(createPostRepositoryProvider);
      final analyticsService = ref.watch(analyticsServiceProvider);

      return CreatePostStateNotifier(repository, analyticsService);
    });

final postListProvider =
    StateNotifierProvider<
      PostListNotifier,
      CursorPaginationState<PostListModel>
    >((ref) {
      return PostListNotifier(ref.watch(createPostRepositoryProvider));
    });

final postDetailProvider =
    StateNotifierProvider.family<PostDetailNotifier, PostDetailState, int>((
      ref,
      postId,
    ) {
      final repository = ref.watch(createPostRepositoryProvider);
      final analyticsService = ref.watch(analyticsServiceProvider);

      return PostDetailNotifier(repository, postId, analyticsService);
    });

final searchPostsUseCaseProvider = Provider<SearchPostsUseCase>((ref) {
  final repository = ref.watch(createPostRepositoryProvider);

  return SearchPostsUseCase(repository);
});

final searchPostProvider =
    StateNotifierProvider<
      SearchPostNotifier,
      CursorPaginationState<PostListModel>
    >((ref) {
      final searchPostsUseCase = ref.watch(searchPostsUseCaseProvider);

      return SearchPostNotifier(searchPostsUseCase);
    });
