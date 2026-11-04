import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/user_blocks/presentation/providers/user_blocks_providers.dart';

class BlockedUsersPage extends ConsumerWidget {
  const BlockedUsersPage({super.key});

  Future<void> _confirmUnblock(
    BuildContext context,
    WidgetRef ref, {
    required int targetUserId,
    required String nickname,
  }) async {
    final notifier = ref.read(blockedUserListProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final l10n = AppLocalizations.of(dialogContext);
        return AlertDialog(
          title: Text(l10n.blockedUsersUnblock),
          content: Text(l10n.blockedUsersUnblockConfirm(nickname)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                MaterialLocalizations.of(dialogContext).cancelButtonLabel,
              ),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(l10n.blockedUsersUnblock),
            ),
          ],
        );
      },
    );
    if (confirmed != true ||
        !context.mounted ||
        !identical(notifier, ref.read(blockedUserListProvider.notifier))) {
      return;
    }

    final result = await notifier.unblockUser(targetUserId);
    if (result == null ||
        !context.mounted ||
        !identical(notifier, ref.read(blockedUserListProvider.notifier))) {
      return;
    }

    final l10n = AppLocalizations.of(context);
    final message = result.fold((failure) {
      if (failure is NetworkFailure ||
          failure is CancelTokenFailure ||
          (failure is ServerFailure &&
              (failure.statusCode == null || failure.statusCode! >= 500))) {
        return l10n.blockedUsersUnblockUnconfirmed;
      }
      return l10n.blockedUsersUnblockFailed;
    }, (_) => l10n.blockedUsersUnblockSucceeded);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isLoggedIn = ref.watch(
      loginProvider.select((state) => state is LoginSuccess),
    );

    if (!isLoggedIn) {
      return DefaultLayout(
        appBarTitle: l10n.settingsBlockedUsers,
        child: Center(child: Text(l10n.blockedUsersLoginRequired)),
      );
    }

    final state = ref.watch(blockedUserListProvider);
    final busy =
        state.isLoading ||
        state.isLoadingMore ||
        state.unblockingUserId != null;
    final Widget body;

    if (state.isLoading && !state.hasLoaded) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.failure != null && state.items.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.blockedUsersLoadFailed),
            TextButton(
              onPressed: state.isLoading
                  ? null
                  : () => ref.read(blockedUserListProvider.notifier).load(),
              child: Text(l10n.blockedUsersRetry),
            ),
          ],
        ),
      );
    } else if (state.hasLoaded && state.items.isEmpty) {
      body = Center(child: Text(l10n.blockedUsersEmpty));
    } else {
      final showFooter =
          state.isLoadingMore ||
          state.isLoadMoreFailure ||
          (state.hasNext && state.nextCursor != null);

      body = ListView.builder(
        itemCount: state.items.length + (showFooter ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == state.items.length) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: state.isLoadingMore
                    ? const CircularProgressIndicator()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (state.isLoadMoreFailure)
                            Text(
                              l10n.blockedUsersLoadFailed,
                              textAlign: TextAlign.center,
                            ),
                          OutlinedButton(
                            onPressed: busy
                                ? null
                                : () => ref
                                      .read(blockedUserListProvider.notifier)
                                      .loadMore(),
                            child: Text(
                              state.isLoadMoreFailure
                                  ? l10n.blockedUsersRetry
                                  : l10n.blockedUsersLoadMore,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }

          final user = state.items[index];
          final nickname = user.nickname?.trim();
          final displayName = nickname != null && nickname.isNotEmpty
              ? nickname
              : l10n.blockedUsersUnknownName;

          return ListTile(
            key: ValueKey(user.userId),
            leading: const CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(displayName),
            trailing: state.unblockingUserId == user.userId
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton(
                    onPressed: busy
                        ? null
                        : () => _confirmUnblock(
                            context,
                            ref,
                            targetUserId: user.userId,
                            nickname: displayName,
                          ),
                    child: Text(l10n.blockedUsersUnblock),
                  ),
          );
        },
      );
    }

    return DefaultLayout(
      appBarTitle: l10n.settingsBlockedUsers,
      child: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: body,
          ),
        ),
      ),
    );
  }
}
