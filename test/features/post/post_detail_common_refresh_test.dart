import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/features/comments/presentation/providers/comment_provider.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_cache_providers.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_local_data_source.dart';
import 'package:loop/src/features/post/presentation/pages/board_detail_page.dart';
import 'package:loop/src/features/post/presentation/pages/board_page.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_list_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/user_block_model.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/user_blocks_providers.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'post_detail_retry_test.dart' show DetailRepository, DetailAnalytics;
import 'post_cache_session_test.dart' show AuthFake, GoogleFake, KakaoFake;
import 'post_cache_test.dart' show PageResult, page;

typedef CommentsResult = Either<Failure, CursorPaginatedResponse<CommentModel>>;
typedef BlockResult = Either<Failure, UserBlockModel>;

class BlockRepository implements AbstractUserBlocksRepository {
  final targetIds = <int>[];
  late final pending = Completer<BlockResult>();
  bool isBlocked = true;

  @override
  Future<Either<Failure, BlockedUserListModel>> getBlockedUsers({
    int limit = 20,
    String? cursor,
  }) async => Right(
    BlockedUserListModel(
      items: [
        if (isBlocked)
          BlockedUserModel(
            blockId: 1,
            userId: 1,
            nickname: 'Author',
            profileImageUrl: null,
            blockedAt: DateTime.utc(2026),
          ),
      ],
      nextCursor: null,
      hasNext: false,
    ),
  );

  @override
  Future<BlockResult> blockUser({required int targetUserId}) {
    targetIds.add(targetUserId);
    return pending.future;
  }

  @override
  Future<Either<Failure, Unit>> unblockUser({required int targetUserId}) async {
    isBlocked = false;
    return const Right(unit);
  }
}

class _VisibilityCache implements PostLocalDataSource {
  int invalidations = 0;

  @override
  Future<void> invalidate() async => invalidations++;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _VisibilityPosts extends DetailRepository {
  final searches = <(String, String?)>[];
  int visibleId = 1;

  _VisibilityPosts() {
    response = (_) async => page(visibleId, 1, cursor: 'next');
  }

  @override
  Future<PageResult> searchPosts({
    required String keyword,
    String? cursor,
  }) async {
    searches.add((keyword, cursor));
    return page(visibleId, 1);
  }
}

class CommentsRepository implements AbstractCommentRepository {
  int calls = 0;
  bool offline = true;
  Completer<CommentsResult>? pending;
  @override
  Future<CommentsResult> getComments({
    required int postId,
    String? cursor,
  }) async {
    calls++;
    if (pending != null) return pending!.future;
    if (offline) return const Left(NetworkFailure('comments offline'));
    return const Right(CursorPaginatedResponse(items: [], hasNext: false));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _VisibilityPosts posts;
  late CommentsRepository comments;
  late BlockRepository blocks;
  late _VisibilityCache cache;
  late ProviderContainer container;
  setUp(() {
    posts = _VisibilityPosts();
    comments = CommentsRepository();
    blocks = BlockRepository();
    cache = _VisibilityCache();
    container = ProviderContainer(
      overrides: [
        createPostRepositoryProvider.overrideWithValue(posts),
        postLocalDataSourceProvider.overrideWithValue(cache),
        commentRepositoryProvider.overrideWithValue(comments),
        userBlocksRepositoryProvider.overrideWithValue(blocks),
        analyticsServiceProvider.overrideWithValue(DetailAnalytics()),
        loginProvider.overrideWith(
          (ref) => LoginStateNotifier(
            AuthFake(),
            const FlutterSecureStorage(),
            KakaoFake(),
            GoogleFake(),
            DetailAnalytics(),
          ),
        ),
      ],
    );
  });
  tearDown(() {
    container.dispose();
  });
  Future<GoRouter> showPage(
    WidgetTester tester, {
    int postId = 1,
    bool fromBoard = false,
    String? searchKeyword,
  }) async {
    final router = GoRouter(
      initialLocation: fromBoard ? '/board' : '/posts/$postId',
      routes: [
        GoRoute(
          path: '/board',
          builder: (_, _) => searchKeyword == null
              ? const Scaffold(body: Text('Board'))
              : const BoardPage(),
        ),
        GoRoute(
          path: '/posts/:postId',
          builder: (_, state) => BoardDetailPage(
            postId: int.parse(state.pathParameters['postId']!),
          ),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      ),
    );
    await tester.pumpAndSettle();
    if (fromBoard) {
      if (searchKeyword != null) {
        await tester.enterText(find.byType(TextField), searchKeyword);
        await tester.pump(const Duration(milliseconds: 400));
        await tester.pumpAndSettle();
      }
      unawaited(router.push<void>('/posts/$postId'));
      await tester.pumpAndSettle();
    }
    return router;
  }

  final blockButton = find.ancestor(
    of: find.text('Block author'),
    matching: find.byWidgetPredicate((widget) => widget is OutlinedButton),
  );
  final confirmBlock = find.widgetWithText(FilledButton, 'Block author');

  Future<void> login() => container
      .read(loginProvider.notifier)
      .login(email: 'test@example.com', password: 'test');

  BlockResult successfulBlock() =>
      Right(UserBlockModel(blockedUserId: 1, blockedAt: DateTime.utc(2026)));

  testWidgets('block button is hidden for guests and the post author', (
    tester,
  ) async {
    posts.offline = false;
    comments.offline = false;
    await showPage(tester);
    expect(blockButton, findsNothing);

    await login();
    await tester.pumpAndSettle();
    expect(blockButton, findsOneWidget);

    final loginNotifier = container.read(loginProvider.notifier);
    final user = (container.read(loginProvider) as LoginSuccess).user;
    await loginNotifier.updateUser(user.copyWith(id: 1));
    await tester.pumpAndSettle();
    expect(blockButton, findsNothing);
  });

  testWidgets('canceling does not submit a block request', (tester) async {
    posts.offline = false;
    comments.offline = false;
    await login();
    await showPage(tester);
    await tester.tap(blockButton);
    await tester.pumpAndSettle();
    expect(blocks.targetIds, isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(blocks.targetIds, isEmpty);
    expect(confirmBlock, findsNothing);
  });

  testWidgets('confirmation sends the author id once and reports success', (
    tester,
  ) async {
    posts.offline = false;
    comments.offline = false;
    await login();
    await showPage(
      tester,
      postId: 55,
      fromBoard: true,
      searchKeyword: 'Flutter',
    );
    final list = container.read(postListProvider.notifier);
    final oldPage = Completer<PageResult>();
    posts.response = (cursor) =>
        cursor == null ? Future.value(page(2, 1)) : oldPage.future;
    final loadMore = list.loadMore();
    await tester.tap(blockButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmBlock);
    await tester.pumpAndSettle();

    expect(blocks.targetIds, [1]);
    expect(tester.widget<OutlinedButton>(blockButton).onPressed, isNull);
    posts.visibleId = 2;
    blocks.pending.complete(successfulBlock());
    await tester.pumpAndSettle();
    oldPage.complete(page(1, 1, cursor: 'obsolete'));
    await loadMore;
    await tester.pumpAndSettle();
    expect(find.text('Author blocked.'), findsOneWidget);
    expect(find.byType(BoardPage), findsOneWidget);
    expect(find.text('Body'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Flutter',
    );
    expect(find.text('Post 1'), findsNothing);
    expect(find.text('Post 2'), findsOneWidget);
    expect(cache.invalidations, 1);
    expect(posts.requests, [null, 'next', null]);
    expect(posts.searches, [('Flutter', null), ('Flutter', null)]);
    expect(container.read(postListProvider).items.single.postId, 2);
    expect(container.read(searchPostProvider).items.single.postId, 2);
  });

  testWidgets(
    'a confirmed block refreshes the list even after leaving detail',
    (tester) async {
      posts.offline = false;
      comments.offline = false;
      await login();
      final router = await showPage(tester, fromBoard: true);
      container.read(postListProvider);
      await tester.pumpAndSettle();
      await tester.tap(blockButton);
      await tester.pumpAndSettle();
      await tester.tap(confirmBlock);
      await tester.pumpAndSettle();

      router.pop();
      await tester.pumpAndSettle();
      posts.visibleId = 2;
      blocks.pending.complete(successfulBlock());
      await tester.pumpAndSettle();

      expect(find.text('Board'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
      expect(cache.invalidations, 1);
      expect(container.read(postListProvider).items.single.postId, 2);
    },
  );

  testWidgets('successful block on a direct detail link returns to the board', (
    tester,
  ) async {
    posts.offline = false;
    comments.offline = false;
    await login();
    await showPage(tester);
    await tester.tap(blockButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmBlock);
    await tester.pumpAndSettle();
    blocks.pending.complete(successfulBlock());
    await tester.pumpAndSettle();
    expect(find.text('Board'), findsOneWidget);
    expect(posts.requests, isEmpty); // 목록 화면이 없었다면 미리 조회하지 않음
  });

  testWidgets('late block result is ignored after same-account relogin', (
    tester,
  ) async {
    posts.offline = false;
    comments.offline = false;
    await login();
    await showPage(tester);
    await tester.tap(blockButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmBlock);
    await tester.pumpAndSettle();
    expect(blocks.targetIds, [1]);

    await container.read(loginProvider.notifier).logout();
    await login();
    blocks.pending.complete(successfulBlock());
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);
    expect(cache.invalidations, 0);
  });

  testWidgets('network errors do not imply that the block failed', (
    tester,
  ) async {
    posts.offline = false;
    comments.offline = false;
    await login();
    await showPage(tester);
    await tester.tap(blockButton);
    await tester.pumpAndSettle();
    await tester.tap(confirmBlock);
    await tester.pumpAndSettle();

    blocks.pending.complete(const Left(NetworkFailure('offline')));
    await tester.pumpAndSettle();
    expect(find.textContaining("Couldn't confirm"), findsOneWidget);
    expect(find.text('Author blocked.'), findsNothing);
    expect(find.text('Body'), findsOneWidget);
    expect(cache.invalidations, 0);
  });

  test(
    'unblock success reloads both the blocked users and the post results',
    () async {
      await login();
      final subscription = container.listen(blockedUserListProvider, (_, _) {});
      addTearDown(subscription.close);
      container.read(postListProvider);
      await container.read(searchPostProvider.notifier).search('Flutter');
      await container.pump();
      expect(subscription.read().items.single.userId, 1);

      posts.visibleId = 2;
      final result = await container
          .read(blockedUserListProvider.notifier)
          .unblockUser(1);
      await container.pump();

      expect(result?.isRight(), isTrue);
      expect(subscription.read().items, isEmpty);
      expect(cache.invalidations, 1);
      expect(container.read(postListProvider).items.single.postId, 2);
      expect(container.read(searchPostProvider).items.single.postId, 2);
    },
  );

  testWidgets('shared retry reloads post and comments after offline failure', (
    tester,
  ) async {
    await showPage(tester);
    expect(posts.calls, 1);
    expect(comments.calls, 1);
    posts.offline = false;
    comments.offline = false;
    await tester.tap(find.byKey(const ValueKey('post-detail-retry')));
    await tester.pumpAndSettle();
    expect(posts.calls, 2);
    expect(comments.calls, 2);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('comments offline'), findsNothing);
  });
  testWidgets('comment failure keeps body and uses only toolbar refresh', (
    tester,
  ) async {
    posts.offline = false;
    await showPage(tester);
    expect(find.text('Body'), findsOneWidget);
    expect(find.text('comments offline'), findsOneWidget);
    expect(find.text('Retry'), findsNothing);
    comments.offline = false;
    await tester.tap(find.byKey(const ValueKey('post-detail-refresh')));
    await tester.pumpAndSettle();
    expect(posts.calls, 2);
    expect(comments.calls, 2);
    expect(find.text('comments offline'), findsNothing);
  });
  test('comment failure is discarded when leaving and reentering', () async {
    final first = container.listen(commentListProvider(1), (_, __) {});
    await container.pump();
    expect(first.read().errorMessage, 'comments offline');
    final old = container.read(commentListProvider(1).notifier);
    first.close();
    await container.pump();
    expect(old.mounted, isFalse);
    comments.offline = false;
    final second = container.listen(commentListProvider(1), (_, __) {});
    await container.pump();
    expect(second.read().errorMessage, isNull);
    expect(comments.calls, 2);
    second.close();
  });
  test(
    'late comment response after leaving does not write disposed state',
    () async {
      comments.pending = Completer<CommentsResult>();
      final sub = container.listen(commentListProvider(1), (_, __) {});
      final notifier = container.read(commentListProvider(1).notifier);
      sub.close();
      await container.pump();
      expect(notifier.mounted, isFalse);
      comments.pending!.complete(
        const Right(CursorPaginatedResponse(items: [], hasNext: false)),
      );
      await Future<void>.delayed(Duration.zero);
    },
  );
}
