import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/user_blocks/domain/models/blocked_user_model.dart';

part 'blocked_user_list_state.freezed.dart';

@freezed
abstract class BlockedUserListState with _$BlockedUserListState {
  const factory BlockedUserListState({
    @Default([]) List<BlockedUserModel> items,
    String? nextCursor,
    @Default(false) bool hasNext,

    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool hasLoaded,
    int? unblockingUserId,

    Failure? failure,
    @Default(false) bool isLoadMoreFailure,
  }) = _BlockedUserListState;
}
