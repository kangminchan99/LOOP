import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/layout/max_width_container.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/chat/presentation/providers/chat_providers.dart';
import 'package:loop/src/features/comments/presentation/providers/comment_provider.dart';
import 'package:loop/src/features/comments/presentation/widgets/comment_input_widget.dart';
import 'package:loop/src/features/comments/presentation/widgets/comment_item_widget.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';

class BoardDetailPage extends ConsumerWidget {
  const BoardDetailPage({required this.postId, super.key});

  final int postId;

  // 본문과 댓글은 함께 재조회하되 각자의 성공/실패 상태는 유지.
  Future<void> _reload(WidgetRef ref) async {
    final postState = ref.read(postDetailProvider(postId));
    final commentsState = ref.read(commentListProvider(postId));
    if (postState is PostDetailLoading ||
        postState is PostDetailDeleting ||
        commentsState.isLoading ||
        commentsState.isLoadingMore) {
      return;
    }
    final detail = ref.read(postDetailProvider(postId).notifier);
    final comments = ref.read(commentListProvider(postId).notifier);
    await Future.wait<void>([detail.load(), comments.load()]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(postDetailProvider(postId));

    final loginState = ref.watch(loginProvider);
    final myId = loginState is LoginSuccess ? loginState.user.id : null;

    final commentState = ref.watch(commentListProvider(postId));
    final commentNotifier = ref.read(commentListProvider(postId).notifier);
    final isLoggedIn = loginState is LoginSuccess;
    final isBusy =
        state is PostDetailLoading ||
        state is PostDetailDeleting ||
        commentState.isLoading ||
        commentState.isLoadingMore;

    ref.listen(postDetailProvider(postId), (_, next) {
      if (next is PostDetailDeleted) {
        ref.read(postListProvider.notifier).removePost(postId);
        context.pop();
      }
      if (next is PostDetailError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    return DefaultLayout(
      appBarTitle: '게시글',
      actions: [
        IconButton(
          key: const ValueKey('post-detail-refresh'),
          tooltip: AppLocalizations.of(context).postsRefresh,
          onPressed: isBusy ? null : () => _reload(ref),
          icon: const Icon(Icons.refresh),
        ),
        if (state is PostDetailSuccess &&
            myId != null &&
            state.post.authorId == myId) ...[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.pushNamed(
                AppRoute.postEdit.name,
                pathParameters: {'postId': postId.toString()},
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ],
      child: RefreshIndicator(
        onRefresh: () => _reload(ref),
        child: switch (state) {
          PostDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          PostDetailDeleting() => const Center(
            child: CircularProgressIndicator(),
          ),
          PostDetailError(:final message) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    key: const ValueKey('post-detail-retry'),
                    onPressed: isBusy ? null : () => _reload(ref),
                    icon: const Icon(Icons.refresh),
                    label: Text(AppLocalizations.of(context).postsRetry),
                  ),
                ],
              ),
            ),
          ),
          PostDetailSuccess(:final post) ||
          PostDetailDeleting(:final post) => MaxWidthContainer(
            maxWidth: 720,
            padding: EdgeInsets.zero,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (post.summaryStatus == 'COMPLETED' && post.summary != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI 요약',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(post.summary!),
                        ],
                      ),
                    ),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Helpers().formatDate(post.updatedAt),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                  ),
                  if (isLoggedIn && post.authorId != myId) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _startChatWithAuthor(
                          context: context,
                          ref: ref,
                          targetUserId: post.authorId,
                        ),
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('작성자와 채팅하기'),
                      ),
                    ),
                  ],
                  const Divider(height: 32),
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 16, height: 1.6),
                  ),

                  const Divider(height: 40),

                  Text(
                    '댓글 ${commentState.items.length}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  CommentInputWidget(
                    enabled: isLoggedIn,
                    onSubmit: (content) async {
                      final result = await commentNotifier.create(content);
                      if (!context.mounted) return;

                      result.match((failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(failure.errorMessage)),
                        );
                      }, (_) {});
                    },
                  ),

                  const SizedBox(height: 16),

                  if (commentState.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        commentState.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  if (commentState.isLoading && commentState.items.isEmpty)
                    const Center(child: CircularProgressIndicator())
                  else if (commentState.items.isEmpty &&
                      commentState.errorMessage == null)
                    const Center(child: Text('아직 댓글이 없습니다.'))
                  else if (commentState.items.isNotEmpty)
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: commentState.items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final comment = commentState.items[index];

                        return CommentItemWidget(
                          comment: comment,
                          myId: myId,
                          onDeleteTap: () async {
                            final result = await commentNotifier.delete(
                              comment.id,
                            );
                            if (!context.mounted) return;

                            result.match((failure) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(failure.errorMessage)),
                              );
                            }, (_) {});
                          },
                        );
                      },
                    ),

                  if (commentState.isLoadingMore)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  if (commentState.hasNext &&
                      commentState.nextCursor != null &&
                      commentState.errorMessage == null)
                    TextButton(
                      onPressed: isBusy ? null : commentNotifier.loadMore,
                      child: const Text('댓글 더보기'),
                    ),
                ],
              ),
            ),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  Future<void> _startChatWithAuthor({
    required BuildContext context,
    required WidgetRef ref,
    required int targetUserId,
  }) async {
    final result = await ref
        .read(chatUseCaseProvider)
        .createDirectRoom(targetUserId: targetUserId);

    if (!context.mounted) return;

    result.match(
      (failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.errorMessage)));
      },
      (room) {
        context.pushNamed(
          AppRoute.chatRoomDetail.name,
          pathParameters: {'roomId': room.id.toString()},
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: const Text('정말 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => context.pop(), child: const Text('취소')),
          TextButton(
            onPressed: () {
              context.pop();
              ref.read(postDetailProvider(postId).notifier).delete();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
