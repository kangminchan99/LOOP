import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
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
  return BlockUserUseCase(ref.watch(userBlocksRepositoryProvider));
});

final unblockUserUseCaseProvider = Provider<UnblockUserUseCase>((ref) {
  return UnblockUserUseCase(ref.watch(userBlocksRepositoryProvider));
});

final getBlockedUsersUseCaseProvider = Provider<GetBlockedUsersUseCase>((ref) {
  return GetBlockedUsersUseCase(ref.watch(userBlocksRepositoryProvider));
});

final blockedUserListProvider =
    StateNotifierProvider.autoDispose<
      BlockedUserListNotifier,
      BlockedUserListState
    >((ref) {
      final loginState = ref.read(loginProvider);
      final userId = loginState is LoginSuccess ? loginState.user.id : null;
      var sessionValid = true;

      ref.onDispose(() {
        sessionValid = false;
      });

      ref.listen<LoginState>(loginProvider, (previous, next) {
        final nextUserId = next is LoginSuccess ? next.user.id : null;
        if (nextUserId != userId) {
          sessionValid = false;
          ref.invalidateSelf();
        }
      });

      bool isSessionCurrent() {
        if (!sessionValid || userId == null) return false;

        final current = ref.read(loginProvider);
        return current is LoginSuccess && current.user.id == userId;
      }

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
