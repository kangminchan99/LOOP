import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/get_blocked_users_usecase.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/unblock_user_usecase.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/blocked_user_list_state.dart';

class BlockedUserListNotifier extends StateNotifier<BlockedUserListState> {
  BlockedUserListNotifier({
    required GetBlockedUsersUseCase getBlockedUsersUseCase,
    required UnblockUserUseCase unblockUserUseCase,
    required bool Function() isSessionCurrent,
  }) : _getBlockedUsersUseCase = getBlockedUsersUseCase,
       _unblockUserUseCase = unblockUserUseCase,
       _isSessionCurrent = isSessionCurrent,
       super(const BlockedUserListState());

  final GetBlockedUsersUseCase _getBlockedUsersUseCase;
  final UnblockUserUseCase _unblockUserUseCase;
  final bool Function() _isSessionCurrent;

  bool get _canUpdate => mounted && _isSessionCurrent();

  bool get _isBusy =>
      state.isLoading || state.isLoadingMore || state.unblockingUserId != null;

  Future<void> load() async {
    if (!_canUpdate || _isBusy) return;

    state = state.copyWith(
      isLoading: true,
      failure: null,
      isLoadMoreFailure: false,
    );
    await _loadFirstPage();
  }

  Future<void> _loadFirstPage() async {
    // 커서를 넘기지 않으므로 첫 페이지를 요청한다.
    final result = await _getBlockedUsersUseCase();

    // 화면이 종료되거나 계정이 바뀌었다면 이전 응답을 반영하지 않는다.
    if (!_canUpdate) return;

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
      },
      (page) {
        state = state.copyWith(
          items: page.items,
          nextCursor: page.nextCursor,
          hasNext: page.hasNext,
          isLoading: false,
          hasLoaded: true,
          failure: null,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (!_canUpdate || !state.hasLoaded || _isBusy || !state.hasNext) {
      return;
    }

    final cursor = state.nextCursor;
    if (cursor == null) return;

    state = state.copyWith(
      isLoadingMore: true,
      failure: null,
      isLoadMoreFailure: false,
    );

    final result = await _getBlockedUsersUseCase(cursor: cursor);
    if (!_canUpdate) return;

    result.fold(
      (failure) {
        // 기존 목록과 커서를 유지해 같은 페이지를 재시도할 수 있다.
        state = state.copyWith(
          isLoadingMore: false,
          failure: failure,
          isLoadMoreFailure: true,
        );
      },
      (page) {
        final usersById = {
          for (final user in state.items) user.userId: user,
          for (final user in page.items) user.userId: user,
        };

        state = state.copyWith(
          items: usersById.values.toList(),
          nextCursor: page.nextCursor,
          hasNext: page.hasNext,
          isLoadingMore: false,
        );
      },
    );
  }

  // null은 중복 요청, 이미 사라진 항목, 이전 세션 결과처럼 반영하지 않는 경우다.
  Future<Either<Failure, Unit>?> unblockUser(int targetUserId) async {
    if (!_canUpdate ||
        _isBusy ||
        !state.items.any((user) => user.userId == targetUserId)) {
      return null;
    }

    state = state.copyWith(unblockingUserId: targetUserId);
    final result = await _unblockUserUseCase(
      targetUserId: targetUserId,
      isSessionCurrent: () => _canUpdate,
    );
    if (!_canUpdate) return null;

    if (result.isLeft()) {
      state = state.copyWith(unblockingUserId: null);
      return result;
    }

    // 해제 후 예전 커서는 쓰지 않는다. 재조회 실패 시에도 예전 항목을 복원하지 않는다.
    state = const BlockedUserListState(isLoading: true);
    await _loadFirstPage();
    return _canUpdate ? result : null;
  }
}
