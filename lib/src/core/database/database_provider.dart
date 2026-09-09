import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_database.dart';

// 같은 ProviderScope 안에서 하나의 DB 인스턴스를 공유.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();

  // Provider가 폐기되면 DB 연결과 관련 자원을 정리.
  ref.onDispose(() async {
    await database.close();
  });

  return database;
});
