import 'package:drift/drift.dart';

// 서버에서 조회한 게시글 목록을 기기에 저장하는 테이블.
@DataClassName('CachedPost')
class CachedPosts extends Table {
  // 서버 게시글 ID를 그대로 사용.
  IntColumn get postId => integer()();

  // 서버에서 받은 목록 순서를 보존 (시간의 초 이하 정밀도와 무관).
  IntColumn get position => integer().withDefault(const Constant(0))();

  TextColumn get title => text()();

  TextColumn get authorNickname => text()();

  // 서버에서 게시글이 작성된 시각.
  DateTimeColumn get createdAt => dateTime()();

  // 기기에 저장한 시각. 이후 캐시 만료 판단에 사용.
  DateTimeColumn get cachedAt => dateTime()();

  // 같은 게시글이 중복 저장되지 않도록 지정.
  @override
  Set<Column> get primaryKey => {postId};
}
