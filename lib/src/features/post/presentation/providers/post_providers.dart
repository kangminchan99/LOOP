import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_cache_providers.dart';
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
  ref.watch(postCacheSessionProvider);
  final api = ref.watch(postApiProvider);
  final localDataSource = ref.watch(postLocalDataSourceProvider);
  final storage = ref.watch(secureStorageProvider);
  final viewer = ref.watch(
    loginProvider.select(
      (state) => (
        isAuthenticated: state is LoginSuccess,
        isGuest: state is LoginInitial || state is LoginError,
      ),
    ),
  );
  var active = true;
  ref.onDispose(() => active = false);

  return PostRepositoryImpl(
    api,
    localDataSource,
    allowPublicCache: viewer.isGuest,
    requireAuthenticatedViewer: viewer.isAuthenticated,
    // 세션 복원 전/실패 후에도 토큰이 있으면 공개 캐시를 보여주지 않는다.
    canReadPublicCache: () async {
      if (!active) return false;
      final token = await storage.read(key: kAccessTokenKey);
      return active && (token == null || token.isEmpty);
    },
  );
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

final postDetailProvider = StateNotifierProvider.autoDispose
    .family<PostDetailNotifier, PostDetailState, int>((ref, postId) {
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

final refreshPostVisibilityProvider = Provider<void Function()>((ref) {
  final logger = Logger('PostVisibility');

  Future<void> discardOldCache() async {
    try {
      await ref.read(postLocalDataSourceProvider).invalidate();
    } catch (error, stack) {
      logger.warning('게시글 가시성 변경 후 캐시 정리 실패', error, stack);
    }
  }

  return () {
    // invalidate()는 삭제를 기다리기 전에 revision을 바꿔 이전 쓰기를 막는다.
    unawaited(discardOldCache());
    if (ref.exists(postListProvider)) {
      unawaited(
        ref.read(postListProvider.notifier).reloadAfterVisibilityChange(),
      );
    }
    if (ref.exists(searchPostProvider)) {
      unawaited(
        ref.read(searchPostProvider.notifier).reloadAfterVisibilityChange(),
      );
    }
  };
});
