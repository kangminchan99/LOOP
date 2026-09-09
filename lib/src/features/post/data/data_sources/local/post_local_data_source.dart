import 'package:drift/drift.dart';
import 'package:loop/src/core/database/app_database.dart';
import 'package:loop/src/features/post/domain/models/post_cache_policy.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';

class PostLocalDataSource {
  PostLocalDataSource(this._database, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;
  Future<void> _pending = Future<void>.value();
  int _revision = 0;
  int _session = 0;
  int get revision => _revision;
  int get session => _session;

  // 읽기·저장·삭제 순서를 유지. 한 작업의 실패가 다음 작업을 막지 않음.
  Future<T> _serial<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return result;
  }

  Future<void> saveSnapshot(
    List<PostListModel> freshPosts, {
    int? expectedRevision,
    DateTime? fetchedAt,
  }) {
    final expected = expectedRevision ?? _revision;
    final savedAt = (fetchedAt ?? _now()).toUtc();
    final seen = <int>{};
    var position = 0;
    final entries = freshPosts
        .where((post) => seen.add(post.postId))
        .take(kMaxCachedPosts)
        .map(
          (post) => CachedPostsCompanion.insert(
            postId: Value(post.postId),
            title: post.title,
            position: Value(position++),
            authorNickname: post.authorNickname,
            createdAt: post.createdAt,
            cachedAt: savedAt,
          ),
        )
        .toList();
    return _serial(() async {
      // 로그아웃/수정/삭제 전에 시작한 응답은 캐시를 덮어쓰지 못함.
      if (expected != _revision) return;
      await _database.transaction(() async {
        await _database.delete(_database.cachedPosts).go();
        if (entries.isNotEmpty) {
          await _database.batch(
            (batch) => batch.insertAll(_database.cachedPosts, entries),
          );
        }
      });
    });
  }

  Future<List<PostListModel>> getCachedPosts() => _serial(() async {
    return _database.transaction(() async {
      await _deleteExpired();
      final rows =
          await (_database.select(_database.cachedPosts)
                ..orderBy([(t) => OrderingTerm.asc(t.position)])
                ..limit(kMaxCachedPosts))
              .get();
      return rows
          .map(
            (row) => PostListModel(
              postId: row.postId,
              title: row.title,
              authorNickname: row.authorNickname,
              createdAt: row.createdAt,
            ),
          )
          .toList();
    });
  });

  Future<void> _deleteExpired() async {
    final cutoff = _now().toUtc().subtract(kPostCacheLifetime);
    await (_database.delete(
      _database.cachedPosts,
    )..where((t) => t.cachedAt.isSmallerOrEqualValue(cutoff))).go();
  }

  Future<void> deleteExpired() => _serial(_deleteExpired);

  Future<void> removePost(int postId) {
    _revision++;
    return _serial(() async {
      await (_database.delete(
        _database.cachedPosts,
      )..where((t) => t.postId.equals(postId))).go();
    });
  }

  Future<void> updateTitle(int postId, String title) {
    _revision++;
    return _serial(() async {
      // 제목만 변경하며 기존 저장 시각을 갱신하지 않음.
      await (_database.update(_database.cachedPosts)
            ..where((t) => t.postId.equals(postId)))
          .write(CachedPostsCompanion(title: Value(title)));
    });
  }

  // 게시글 변경은 인증 세션을 바꾸지 않고 목록만 무효화.
  Future<void> invalidate() {
    _revision++;
    return _serial(() async {
      await _database.delete(_database.cachedPosts).go();
    });
  }

  Future<void> clear() {
    _session++;
    return invalidate();
  }
}
