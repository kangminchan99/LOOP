import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/user_blocks/data/data_sources/remote/user_blocks_api.dart';
import 'package:loop/src/features/user_blocks/data/repositories/user_blocks_repository_impl.dart';
import 'package:loop/src/features/user_blocks/domain/repositories/abstract_user_blocks_repository.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/block_user_usecase.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/get_blocked_users_usecase.dart';
import 'package:loop/src/features/user_blocks/domain/usecases/unblock_user_usecase.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/blocked_user_list_notifier.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/blocked_user_list_state.dart';

final userBlocksApiProvider = Provider<UserBlocksApi>((ref) {
  final dio = ref.watch(dioProvider);
  return UserBlocksApi(dio);
});

final userBlocksRepositoryProvider = Provider<AbstractUserBlocksRepository>((
  ref,
) {
  final api = ref.watch(userBlocksApiProvider);
  return UserBlocksRepositoryImpl(api);
});

final blockUserUseCaseProvider = Provider<BlockUserUseCase>((ref) {
  return BlockUserUseCase(
    ref.watch(userBlocksRepositoryProvider),
    onVisibilityChanged: () {
      ref.read(refreshPostVisibilityProvider)();
      ref.invalidate(blockedUserListProvider);
    },
  );
});

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(
    ref.watch(userBlocksRepositoryProvider),
    onVisibilityChanged: () => ref.read(refreshPostVisibilityProvider)(),
  );
});

final getBlockedUsersUseCaseProvider = Provider<GetBlockedUsersUseCase>((ref) {
  return GetBlockedUsersUseCase(ref.watch(userBlocksRepositoryProvider));
});

// 화면을 떠나도 같은 로그인 세션이면 서버가 확정한 차단·해제를 게시판에 반영한다.
final captureUserBlockSessionProvider = Provider<bool Function()>((ref) {
  int? userIdOf(LoginState state) =>
      state is LoginSuccess ? state.user.id : null;
  final userId = userIdOf(ref.read(loginProvider));
  var valid = userId != null;

  ref.onDispose(() => valid = false);
  ref.listen(loginProvider.select(userIdOf), (_, next) {
    if (next == userId) return;
    valid = false;
    ref.invalidateSelf();
  });

  return () => valid;
});

final blockedUserListProvider =
    StateNotifierProvider.autoDispose<
      BlockedUserListNotifier,
      BlockedUserListState
    >((ref) {
      final isSessionCurrent = ref.watch(captureUserBlockSessionProvider);

      final notifier = BlockedUserListNotifier(
        getBlockedUsersUseCase: ref.watch(getBlockedUsersUseCaseProvider),
        unblockUserUseCase: ref.watch(unblockUserUseCaseProvider),
        isSessionCurrent: isSessionCurrent,
      );

      if (isSessionCurrent()) {
        unawaited(notifier.load());
      }

      return notifier;
    });
