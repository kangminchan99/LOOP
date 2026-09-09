import 'dart:async';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/database/app_database.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/local/post_local_data_source.dart';
import 'package:loop/src/features/post/data/data_sources/remote/post_api.dart';
import 'package:loop/src/features/post/data/repositories/post_repository_impl.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/presentation/widgets/post_cache_status.dart';
import 'post_cache_test.dart' show post;

class TestApi extends PostApi {
  TestApi() : super(Dio());
  bool failMutation = false;
  Completer<Response<Map<String, dynamic>>>? pending;
  Response<Map<String, dynamic>> response(Map<String, dynamic> data) =>
      Response(
        requestOptions: RequestOptions(path: '/posts'),
        statusCode: 200,
        data: data,
      );
  @override
  Future<Response<Map<String, dynamic>>> getPosts({
    int limit = 20,
    String? cursor,
  }) async {
    if (pending != null) return pending!.future;
    return response({
      'items': [post(1).toJson()],
      'hasNext': false,
      'nextCursor': null,
    });
  }

  @override
  Future<Response<void>> deletePost(int postId) async {
    if (failMutation) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts/$postId'),
      );
    }
    return Response<void>(
      requestOptions: RequestOptions(path: '/posts/$postId'),
      statusCode: 204,
    );
  }

  @override
  Future<Response<Map<String, dynamic>>> updatePost(
    int postId,
    PostRequestModel request,
  ) async {
    if (failMutation) {
      throw DioException(
        requestOptions: RequestOptions(path: '/posts/$postId'),
      );
    }
    return response({
      'id': postId,
      'title': request.title,
      'content': request.content,
      'authorId': 1,
      'createdAt': '2026-09-01T00:00:00Z',
      'updatedAt': '2026-09-09T00:00:00Z',
    });
  }
}

void main() {
  group('Repository + SQLite', () {
    late AppDatabase db;
    late PostLocalDataSource source;
    late TestApi api;
    late PostRepositoryImpl repository;
    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
      source = PostLocalDataSource(db);
      api = TestApi();
      repository = PostRepositoryImpl(api, source);
    });
    tearDown(() async {
      await db.close();
    });
    test('successful edit and delete update persisted cache', () async {
      await source.saveSnapshot([post(1), post(2)]);
      final edited = await repository.updatePost(
        1,
        const PostRequestModel(title: 'Edited', content: 'Content'),
      );
      expect(edited.isRight(), isTrue);
      expect((await source.getCachedPosts()).first.title, 'Edited');
      final deleted = await repository.deletePost(2);
      expect(deleted.isRight(), isTrue);
      expect((await source.getCachedPosts()).map((p) => p.postId), [1]);
    });
    test('failed server mutation leaves cache untouched', () async {
      await source.saveSnapshot([post(1)]);
      api.failMutation = true;
      expect((await repository.deletePost(1)).isLeft(), isTrue);
      expect(
        (await repository.updatePost(
          1,
          const PostRequestModel(title: 'New', content: 'C'),
        )).isLeft(),
        isTrue,
      );
      expect((await source.getCachedPosts()).single.title, 'Post 1');
    });
    test(
      'old repository cannot write after logout but new session can',
      () async {
        await repository.getPosts();
        await repository.savePostsCache([post(1)]);
        await source.clear();
        await repository.savePostsCache([post(1)]);
        expect(await source.getCachedPosts(), isEmpty);
        final newSession = PostRepositoryImpl(api, source);
        await newSession.getPosts();
        await newSession.savePostsCache([post(2)]);
        expect((await source.getCachedPosts()).single.postId, 2);
      },
    );
    test('response that arrives after logout is rejected', () async {
      api.pending = Completer<Response<Map<String, dynamic>>>();
      final request = repository.getPosts();
      await source.clear();
      api.pending!.complete(
        api.response({
          'items': [post(1).toJson()],
          'hasNext': false,
        }),
      );
      final result = await request;
      result.match(
        (failure) => expect(failure, isA<CancelTokenFailure>()),
        (_) => fail('stale response accepted'),
      );
    });
    test(
      'mutation prevents stale list snapshot from restoring old title',
      () async {
        await repository.getPosts();
        await repository.savePostsCache([post(1)]);
        await repository.updatePost(
          1,
          const PostRequestModel(title: 'Edited', content: 'C'),
        );
        await repository.savePostsCache([post(1)]);
        expect((await source.getCachedPosts()).single.title, 'Edited');
      },
    );
  });

  test('v1 cache upgrades to v2 without requiring app data deletion', () async {
    final db = AppDatabase(
      executor: NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE cached_posts (post_id INTEGER PRIMARY KEY, title TEXT NOT NULL, author_nickname TEXT NOT NULL, created_at INTEGER NOT NULL, cached_at INTEGER NOT NULL)',
          );
          sqlite.execute(
            "INSERT INTO cached_posts VALUES (1, 'old', 'author', 1, 1)",
          );
          sqlite.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(db.close);
    final source = PostLocalDataSource(db);
    expect(await source.getCachedPosts(), isEmpty);
    await source.saveSnapshot([post(1)]);
    expect(await source.getCachedPosts(), hasLength(1));
  });

  testWidgets('offline notice fits mobile in both themes and retry works', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var retries = 0;
    for (final brightness in Brightness.values) {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(brightness: brightness),
          home: Scaffold(
            body: PostCacheStatus(
              isFromCache: true,
              isOffline: true,
              isBusy: false,
              hasError: true,
              onRetry: () {
                retries++;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Cannot reach the server'), findsOneWidget);
      await tester.tap(find.text('Retry'));
    }
    expect(retries, 2);
  });
}
