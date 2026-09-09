import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/cached_posts.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [CachedPosts])
class AppDatabase extends _$AppDatabase {
  // 테스트에서는 메모리 DB 등 다른 연결을 주입할 수 있음.
  AppDatabase({QueryExecutor? executor})
    : super(
        executor ??
            driftDatabase(
              name: 'loop_cache',
              native: const DriftNativeOptions(
                // 전용 isolate에서 DB 작업을 수행하고 연결을 공유.
                shareAcrossIsolates: true,
              ),
            ),
      );

  // 테이블 구조를 변경할 때 버전을 올리고 마이그레이션 추가.
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(cachedPosts, cachedPosts.position);
        // v1에는 순서 정보가 없으므로 재조회 가능한 캐시만 비움.
        await delete(cachedPosts).go();
      }
    },
  );
}
