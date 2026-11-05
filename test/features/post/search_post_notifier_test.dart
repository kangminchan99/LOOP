import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/usecases/search_posts_usecase.dart';
import 'package:loop/src/features/post/presentation/providers/search_post/search_post_notifier.dart';

import 'post_cache_test.dart' show FakeRepository, PageResult, page;

class _SearchRepository extends FakeRepository {
  final searches = <(String, String?)>[];
  final responses = <Completer<PageResult>>[];

  @override
  Future<PageResult> searchPosts({required String keyword, String? cursor}) {
    searches.add((keyword, cursor));
    final response = Completer<PageResult>();
    responses.add(response);
    return response.future;
  }
}

void main() {
  late _SearchRepository repository;
  late SearchPostNotifier notifier;

  setUp(() {
    repository = _SearchRepository();
    notifier = SearchPostNotifier(SearchPostsUseCase(repository));
  });
  tearDown(() => notifier.dispose());

  test('늦게 끝난 이전 첫 페이지가 새 검색 결과를 덮어쓰지 않는다', () async {
    final older = notifier.search('Flutter');
    final newer = notifier.search('Dart');
    expect(repository.searches, [('Flutter', null), ('Dart', null)]);

    repository.responses[1].complete(page(2, 1, cursor: 'dart-next'));
    await newer;
    repository.responses[0].complete(page(1, 1, cursor: 'flutter-next'));
    await older;

    expect(notifier.state.items.single.postId, 2);
    expect(notifier.state.nextCursor, 'dart-next');
  });

  test('가시성 변경 시 같은 검색어의 첫 페이지를 조회하고 이전 추가 페이지는 버린다', () async {
    final first = notifier.search(' Flutter ');
    repository.responses[0].complete(page(1, 1, cursor: 'old-next'));
    await first;

    final olderPage = notifier.loadMore();
    final reload = notifier.reloadAfterVisibilityChange();
    expect(repository.searches, [
      ('Flutter', null),
      ('Flutter', 'old-next'),
      ('Flutter', null),
    ]);
    expect(notifier.state.items, isEmpty);
    expect(notifier.state.nextCursor, isNull);
    expect(notifier.state.isLoading, isTrue);

    repository.responses[1].complete(page(2, 1, cursor: 'obsolete'));
    await olderPage;
    expect(notifier.state.items, isEmpty);
    expect(notifier.state.isLoading, isTrue);

    repository.responses[2].complete(page(3, 1, cursor: 'new-next'));
    await reload;
    expect(notifier.state.items.single.postId, 3);
    expect(notifier.state.nextCursor, 'new-next');
  });

  test('검색어를 지우면 늦은 응답을 버리고 빈 검색어로 요청하지 않는다', () async {
    final search = notifier.search('Flutter');
    notifier.clear();
    await notifier.reloadAfterVisibilityChange();
    await notifier.search('  ');
    repository.responses[0].complete(page(1, 1, cursor: 'old-next'));
    await search;

    expect(repository.searches, [('Flutter', null)]);
    expect(notifier.state.items, isEmpty);
    expect(notifier.state.nextCursor, isNull);
    expect(notifier.state.hasNext, isFalse);
    expect(notifier.state.isLoading, isFalse);
  });

  test('가시성 변경 후 재조회가 실패해도 기존 결과나 커서를 복원하지 않는다', () async {
    final search = notifier.search('Flutter');
    repository.responses[0].complete(page(1, 1, cursor: 'old-next'));
    await search;

    final reload = notifier.reloadAfterVisibilityChange();
    repository.responses[1].complete(const Left(NetworkFailure('offline')));
    await reload;

    expect(notifier.state.items, isEmpty);
    expect(notifier.state.nextCursor, isNull);
    expect(notifier.state.hasNext, isFalse);
    expect(notifier.state.errorMessage, 'offline');
    expect(notifier.state.isLoading, isFalse);
  });
}
