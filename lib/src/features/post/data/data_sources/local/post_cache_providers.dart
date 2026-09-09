import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/database/database_provider.dart';
import 'post_local_data_source.dart';

final postLocalDataSourceProvider = Provider<PostLocalDataSource>((ref) {
  return PostLocalDataSource(ref.watch(appDatabaseProvider));
});

// 인증 변경 시 기존 목록과 진행 중인 요청을 폐기하기 위한 번호.
final postCacheSessionProvider = StateProvider<int>((ref) => 0);
