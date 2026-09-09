import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/analytics/analytics_providers.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'post_cache_test.dart' show FakeRepository;
import 'post_cache_session_test.dart' show AnalyticsFake;

typedef DetailResult = Either<Failure, PostDetailModel>;

class DetailRepository extends FakeRepository {
  int calls = 0;
  bool offline = true;
  Completer<DetailResult>? pending;
  @override
  Future<DetailResult> getPostById(int postId) async {
    calls++;
    if (pending != null) return pending!.future;
    if (offline) return const Left(NetworkFailure('offline'));
    return Right(
      PostDetailModel(
        id: postId,
        title: 'Post',
        content: 'Body',
        authorId: 1,
        updatedAt: DateTime.utc(2026),
      ),
    );
  }
}

class DetailAnalytics extends AnalyticsFake {
  @override
  Future<void> logPostView({required int postId}) async {}
}

void main() {
  late DetailRepository repository;
  late ProviderContainer container;
  setUp(() {
    repository = DetailRepository();
    container = ProviderContainer(
      overrides: [
        createPostRepositoryProvider.overrideWithValue(repository),
        analyticsServiceProvider.overrideWithValue(DetailAnalytics()),
      ],
    );
  });
  tearDown(() {
    container.dispose();
  });
  test(
    'leaving failed detail discards state and reentering refetches',
    () async {
      final first = container.listen(postDetailProvider(1), (_, __) {});
      final oldNotifier = container.read(postDetailProvider(1).notifier);
      await container.pump();
      expect(first.read(), isA<PostDetailError>());
      first.close();
      await container.pump();
      expect(oldNotifier.mounted, isFalse);
      repository.offline = false;
      final second = container.listen(postDetailProvider(1), (_, __) {});
      await container.pump();
      expect(second.read(), isA<PostDetailSuccess>());
      expect(repository.calls, 2);
      second.close();
    },
  );
  test(
    'retry recovers error and duplicate retry does not send two requests',
    () async {
      final sub = container.listen(postDetailProvider(1), (_, __) {});
      await container.pump();
      final notifier = container.read(postDetailProvider(1).notifier);
      repository.pending = Completer<DetailResult>();
      final retry = notifier.load();
      await notifier.load();
      expect(repository.calls, 2);
      repository.pending!.complete(
        Right(
          PostDetailModel(
            id: 1,
            title: 'Post',
            content: 'Body',
            authorId: 1,
            updatedAt: DateTime.utc(2026),
          ),
        ),
      );
      await retry;
      expect(sub.read(), isA<PostDetailSuccess>());
      sub.close();
    },
  );
  test(
    'edit screen listener keeps detail state alive until both leave',
    () async {
      repository.offline = false;
      final detail = container.listen(postDetailProvider(1), (_, __) {});
      final edit = container.listen(postDetailProvider(1), (_, __) {});
      await container.pump();
      final notifier = container.read(postDetailProvider(1).notifier);
      edit.close();
      await container.pump();
      expect(notifier.mounted, isTrue);
      expect(repository.calls, 1);
      detail.close();
      await container.pump();
      expect(notifier.mounted, isFalse);
    },
  );
}
