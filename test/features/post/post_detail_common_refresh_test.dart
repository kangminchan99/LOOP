import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/features/comments/presentation/providers/comment_provider.dart';
import 'package:loop/src/features/post/presentation/pages/board_detail_page.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'post_detail_retry_test.dart' show DetailRepository, DetailAnalytics;
import 'post_cache_session_test.dart' show AuthFake, GoogleFake, KakaoFake;

typedef CommentsResult = Either<Failure, CursorPaginatedResponse<CommentModel>>;

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
  late DetailRepository posts;
  late CommentsRepository comments;
  late ProviderContainer container;
  setUp(() {
    posts = DetailRepository();
    comments = CommentsRepository();
    container = ProviderContainer(
      overrides: [
        createPostRepositoryProvider.overrideWithValue(posts),
        commentRepositoryProvider.overrideWithValue(comments),
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
  Future<void> showPage(WidgetTester tester) async {
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const BoardDetailPage(postId: 1),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

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
