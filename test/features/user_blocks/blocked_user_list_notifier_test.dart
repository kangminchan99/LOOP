import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_list_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_model.dart';
import 'package:loop/src/features/user_blocks/domain/models/user_block_model.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/get_blocked_users_usecase.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/unblock_user_usecase.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/blocked_user_list_notifier.dart';

const _cursor = '2026-11-04T03:00:00.000Z_10';

BlockedUserListModel _page(List<int> ids, {String? nextCursor}) {
  return BlockedUserListModel(
    items: [
      for (final id in ids)
        BlockedUserModel(
          blockId: id,
          userId: id,
          nickname: null,
          profileImageUrl: null,
          blockedAt: DateTime.utc(2026, 11, 4, 3),
        ),
    ],
    nextCursor: nextCursor,
    hasNext: nextCursor != null,
  );
}

class _FakeRepository implements AbstractUserBlocksRepository {
  _FakeRepository(this._fetch, {this.onUnblock});

  final Future<Either<Failure, BlockedUserListModel>> Function(String?) _fetch;
  final Future<Either<Failure, Unit>> Function(int)? onUnblock;
  final cursors = <String?>[];
  final unblockedIds = <int>[];

  @override
  Future<Either<Failure, BlockedUserListModel>> getBlockedUsers({
    int limit = 20,
    String? cursor,
  }) {
    cursors.add(cursor);
    return _fetch(cursor);
  }

  @override
  Future<Either<Failure, UserBlockModel>> blockUser({
    required int targetUserId,
  }) => throw UnimplementedError();

  @override
  Future<Either<Failure, Unit>> unblockUser({required int targetUserId}) {
    unblockedIds.add(targetUserId);
    return onUnblock!(targetUserId);
  }
}

void main() {
  test('다음 페이지를 중복 요청하지 않고 사용자 ID로 합친다', () async {
    final next = Completer<Either<Failure, BlockedUserListModel>>();
    final repository = _FakeRepository((cursor) async {
      if (cursor == null) return Right(_page([10, 9], nextCursor: _cursor));
      return next.future;
    });
    final notifier = BlockedUserListNotifier(
      getBlockedUsersUseCase: GetBlockedUsersUseCase(repository),
      unblockUserUseCase: UnblockUserUseCase(repository),
      isSessionCurrent: () => true,
    );
    addTearDown(notifier.dispose);

    await notifier.loadMore();
    expect(repository.cursors, isEmpty);
    await notifier.load();

    final pending = notifier.loadMore();
    expect(notifier.state.isLoadingMore, isTrue);
    await notifier.loadMore();
    expect(repository.cursors, [null, _cursor]);
    next.complete(Right(_page([9, 8])));
    await pending;

    expect(notifier.state.items.map((user) => user.userId), [10, 9, 8]);
    expect(notifier.state.isLoadingMore, isFalse);
    expect(notifier.state.hasNext, isFalse);
    expect(notifier.state.nextCursor, isNull);
    await notifier.loadMore();
    expect(repository.cursors, [null, _cursor]);
  });

  test('다음 페이지 실패 후 기존 목록과 커서를 유지하고 같은 커서로 재시도한다', () async {
    var attempts = 0;
    final repository = _FakeRepository((cursor) async {
      if (cursor == null) return Right(_page([10], nextCursor: _cursor));
      if (++attempts == 1) return const Left(NetworkFailure('연결 오류'));
      return Right(_page([9]));
    });
    final notifier = BlockedUserListNotifier(
      getBlockedUsersUseCase: GetBlockedUsersUseCase(repository),
      unblockUserUseCase: UnblockUserUseCase(repository),
      isSessionCurrent: () => true,
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    await notifier.loadMore();
    expect(notifier.state.items.map((user) => user.userId), [10]);
    expect(notifier.state.nextCursor, _cursor);
    expect(notifier.state.isLoadMoreFailure, isTrue);
    expect(notifier.state.isLoadingMore, isFalse);
    expect(notifier.state.failure, isA<NetworkFailure>());

    await notifier.loadMore();
    expect(repository.cursors, [null, _cursor, _cursor]);
    expect(notifier.state.items.map((user) => user.userId), [10, 9]);
    expect(notifier.state.isLoadMoreFailure, isFalse);
    expect(notifier.state.failure, isNull);
  });

  test('해제 성공 후 이전 커서를 폐기하고 첫 페이지부터 조회한다', () async {
    final pendingUnblock = Completer<Either<Failure, Unit>>();
    var fetches = 0;
    final repository = _FakeRepository(
      (_) async => Right(
        ++fetches == 1 ? _page([10, 9], nextCursor: _cursor) : _page([9]),
      ),
      onUnblock: (_) => pendingUnblock.future,
    );
    final notifier = BlockedUserListNotifier(
      getBlockedUsersUseCase: GetBlockedUsersUseCase(repository),
      unblockUserUseCase: UnblockUserUseCase(repository),
      isSessionCurrent: () => true,
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    final pending = notifier.unblockUser(10);
    expect(notifier.state.unblockingUserId, 10);
    expect(await notifier.unblockUser(10), isNull);
    await notifier.loadMore();
    expect(repository.unblockedIds, [10]);
    expect(repository.cursors, [null]);

    pendingUnblock.complete(const Right(unit));
    expect((await pending)?.isRight(), isTrue);
    expect(repository.cursors, [null, null]);
    expect(notifier.state.items.map((user) => user.userId), [9]);
    expect(notifier.state.nextCursor, isNull);
    expect(notifier.state.unblockingUserId, isNull);
  });

  test('해제 요청 실패 시 항목과 커서를 유지한다', () async {
    final repository = _FakeRepository(
      (_) async => Right(_page([10], nextCursor: _cursor)),
      onUnblock: (_) async => const Left(NetworkFailure('연결 오류')),
    );
    final notifier = BlockedUserListNotifier(
      getBlockedUsersUseCase: GetBlockedUsersUseCase(repository),
      unblockUserUseCase: UnblockUserUseCase(repository),
      isSessionCurrent: () => true,
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    expect((await notifier.unblockUser(10))?.isLeft(), isTrue);
    expect(repository.cursors, [null]);
    expect(notifier.state.items.single.userId, 10);
    expect(notifier.state.nextCursor, _cursor);
    expect(notifier.state.unblockingUserId, isNull);
  });

  test('해제 후 목록 조회 실패는 해제 성공을 취소하거나 예전 항목을 복원하지 않는다', () async {
    var fetches = 0;
    final repository = _FakeRepository(
      (_) async => ++fetches == 1
          ? Right(_page([10], nextCursor: _cursor))
          : const Left(NetworkFailure('목록 조회 실패')),
      onUnblock: (_) async => const Right(unit),
    );
    final notifier = BlockedUserListNotifier(
      getBlockedUsersUseCase: GetBlockedUsersUseCase(repository),
      unblockUserUseCase: UnblockUserUseCase(repository),
      isSessionCurrent: () => true,
    );
    addTearDown(notifier.dispose);

    await notifier.load();
    expect((await notifier.unblockUser(10))?.isRight(), isTrue);
    expect(notifier.state.items, isEmpty);
    expect(notifier.state.nextCursor, isNull);
    expect(notifier.state.hasLoaded, isFalse);
    expect(notifier.state.failure, isA<NetworkFailure>());
  });
}
