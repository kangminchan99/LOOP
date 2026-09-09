import 'dart:async';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/database/app_database.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_local_data_source.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/features/post/presentation/providers/post_list/post_list_notifier.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

PostListModel post(int id) => PostListModel(
  postId: id,
  title: 'Post $id',
  authorNickname: 'Author',
  createdAt: DateTime.utc(2026, 9, 1),
);
typedef PageResult = Either<Failure, CursorPaginatedResponse<PostListModel>>;
PageResult page(int start, int count, {String? cursor}) => Right(
  CursorPaginatedResponse(
    items: List.generate(count, (i) => post(start + i)),
    nextCursor: cursor,
    hasNext: cursor != null,
  ),
);
Future<void> settle(PostListNotifier notifier) async {
  for (var i = 0; i < 100; i++) {
    await Future<void>.delayed(Duration.zero);
    if (!notifier.state.isLoading && !notifier.state.isLoadingMore) return;
  }
  fail('Notifier did not settle');
}

class FakeRepository implements AbstractPostRepository {
  List<PostListModel> cached = [];
  List<List<PostListModel>> saved = [];
  List<String?> requests = [];
  bool failSave = false;
  Future<PageResult> Function(String?) response = (_) async =>
      page(1, 20, cursor: '20');
  @override
  Future<PageResult> getPosts({String? cursor}) {
    requests.add(cursor);
    return response(cursor);
  }

  @override
  Future<Either<Failure, List<PostListModel>>> getCachedPosts() async =>
      Right(cached);
  @override
  Future<Either<Failure, void>> savePostsCache(
    List<PostListModel> posts,
  ) async {
    if (failSave) return const Left(CacheFailure('Disk full'));
    saved.add(List.of(posts));
    return const Right(null);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('Local cache', () {
    late AppDatabase db;
    late PostLocalDataSource source;
    late DateTime now;
    setUp(() {
      now = DateTime.utc(2026, 9, 9);
      db = AppDatabase(executor: NativeDatabase.memory());
      source = PostLocalDataSource(db, now: () => now);
    });
    tearDown(() async {
      await db.close();
    });
    test('keeps first 200 unique posts in server order', () async {
      await source.saveSnapshot([
        post(3),
        post(1),
        post(3),
        ...List.generate(220, (i) => post(i + 10)),
      ]);
      final cached = await source.getCachedPosts();
      expect(cached.length, 200);
      expect(cached.take(3).map((p) => p.postId), [3, 1, 10]);
    });
    test('expires at seven days, but not before', () async {
      await source.saveSnapshot([post(1)]);
      now = now
          .add(const Duration(days: 7))
          .subtract(const Duration(seconds: 1));
      expect(await source.getCachedPosts(), hasLength(1));
      now = now.add(const Duration(seconds: 1));
      expect(await source.getCachedPosts(), isEmpty);
    });
    test('later page writes do not renew snapshot lifetime', () async {
      final fetchedAt = now;
      await source.saveSnapshot([post(1)], fetchedAt: fetchedAt);
      now = now.add(const Duration(days: 6));
      await source.saveSnapshot([post(1), post(2)], fetchedAt: fetchedAt);
      now = now.add(const Duration(days: 1));
      expect(await source.getCachedPosts(), isEmpty);
    });
    test('empty successful snapshot clears old posts', () async {
      await source.saveSnapshot([post(1)]);
      await source.saveSnapshot([]);
      expect(await source.getCachedPosts(), isEmpty);
    });
    test('clear rejects an in-flight old snapshot', () async {
      final revision = source.revision;
      final writing = source.saveSnapshot([
        post(1),
      ], expectedRevision: revision);
      final clearing = source.clear();
      await Future.wait([writing, clearing]);
      await source.saveSnapshot([post(2)], expectedRevision: revision);
      expect(await source.getCachedPosts(), isEmpty);
    });
    test('editing and deleting cannot be undone by an old response', () async {
      await source.saveSnapshot([post(1), post(2)]);
      final revision = source.revision;
      await source.updateTitle(1, 'Edited');
      await source.removePost(2);
      await source.saveSnapshot([post(1), post(2)], expectedRevision: revision);
      final cached = await source.getCachedPosts();
      expect(cached.single.title, 'Edited');
      expect(cached.single.postId, 1);
    });
    test('database read error does not poison operation queue', () async {
      await db.customStatement('DROP TABLE cached_posts');
      await expectLater(source.getCachedPosts(), throwsA(anything));
      await db.customStatement(
        'CREATE TABLE cached_posts (post_id INTEGER PRIMARY KEY, position INTEGER NOT NULL DEFAULT 0, title TEXT NOT NULL, author_nickname TEXT NOT NULL, created_at INTEGER NOT NULL, cached_at INTEGER NOT NULL)',
      );
      await source.saveSnapshot([post(1)]);
      expect(await source.getCachedPosts(), hasLength(1));
    });
  });

  group('Post list', () {
    test('shows cache while network is pending then replaces it', () async {
      final pending = Completer<PageResult>();
      final repo = FakeRepository()
        ..cached = [post(99)]
        ..response = (_) => pending.future;
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.items.single.postId, 99);
      expect(notifier.state.isFromCache, isTrue);
      await notifier.loadMore();
      expect(repo.requests, [null]);
      pending.complete(page(1, 20, cursor: '20'));
      await settle(notifier);
      expect(notifier.state.items.first.postId, 1);
      expect(notifier.state.isFromCache, isFalse);
    });
    test('offline keeps cache and retry starts at first page', () async {
      final repo = FakeRepository()
        ..cached = [post(99)]
        ..response = (_) async => const Left(NetworkFailure('offline'));
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      expect(notifier.state.items.single.postId, 99);
      expect(notifier.state.isOffline, isTrue);
      expect(repo.saved, isEmpty);
      repo.response = (_) async => page(1, 20, cursor: '20');
      await notifier.retry();
      expect(repo.requests, [null, null]);
      expect(notifier.state.isOffline, isFalse);
    });
    test('server error is not labelled offline', () async {
      final repo = FakeRepository()
        ..response = (_) async => const Left(ServerFailure('server', 500));
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      expect(notifier.state.isOffline, isFalse);
      expect(notifier.state.errorMessage, 'server');
    });
    test('screen reaches 220 while cache stops at 200', () async {
      final repo = FakeRepository()
        ..response = (cursor) async {
          final start = int.parse(cursor ?? '0');
          return page(start + 1, 20, cursor: '${start + 20}');
        };
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      for (var i = 0; i < 10; i++) {
        await notifier.loadMore();
      }
      expect(notifier.state.items.length, 220);
      expect(repo.saved.last.length, 200);
      expect(repo.saved.length, 10);
      await notifier.load();
      expect(repo.saved.last.length, 20);
    });
    test('next-page retry preserves cursor without duplicates', () async {
      final repo = FakeRepository();
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      repo.response = (_) async => const Left(NetworkFailure('offline'));
      await notifier.loadMore();
      expect(notifier.state.items.length, 20);
      repo.response = (_) async => page(20, 21);
      await notifier.retry();
      expect(repo.requests.last, '20');
      expect(notifier.state.items.length, 40);
      expect(notifier.state.nextCursor, isNull);
      expect(notifier.state.hasNext, isFalse);
    });
    test('cache failure does not turn successful network into error', () async {
      final repo = FakeRepository()..failSave = true;
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      expect(notifier.state.items.length, 20);
      expect(notifier.state.errorMessage, isNull);
    });
    test(
      'dispose ignores late network response and does not save it',
      () async {
        final pending = Completer<PageResult>();
        final repo = FakeRepository()..response = (_) => pending.future;
        final notifier = PostListNotifier(repo);
        await Future<void>.delayed(Duration.zero);
        notifier.dispose();
        pending.complete(page(1, 20));
        await Future<void>.delayed(Duration.zero);
        expect(repo.saved, isEmpty);
      },
    );
    test(
      'local deletion rejects an older pending first-page response',
      () async {
        final repo = FakeRepository();
        final notifier = PostListNotifier(repo);
        addTearDown(notifier.dispose);
        await settle(notifier);
        final pending = Completer<PageResult>();
        repo.response = (_) => pending.future;
        final loading = notifier.load();
        notifier.removePost(1);
        pending.complete(page(1, 20));
        await loading;
        expect(notifier.state.items.any((p) => p.postId == 1), isFalse);
      },
    );
    test('authorization denial does not display cached data', () async {
      final repo = FakeRepository()
        ..cached = [post(99)]
        ..response = (_) async => const Left(ServerFailure('forbidden', 403));
      final notifier = PostListNotifier(repo);
      addTearDown(notifier.dispose);
      await settle(notifier);
      expect(notifier.state.items, isEmpty);
    });
  });
}
