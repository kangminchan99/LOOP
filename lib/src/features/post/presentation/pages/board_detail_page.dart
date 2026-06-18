import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';

class BoardDetailPage extends ConsumerWidget {
  const BoardDetailPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postDetailProvider(postId));

    final loginState = ref.watch(loginProvider);
    final myId = loginState is LoginSuccess ? loginState.user.id : null;

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
      child: switch (state) {
        PostDetailLoading() => const Center(child: CircularProgressIndicator()),
        PostDetailDeleting() => const Center(
          child: CircularProgressIndicator(),
        ),
        PostDetailError(:final message) => Center(child: Text(message)),
        PostDetailSuccess(:final post) ||
        PostDetailDeleting(:final post) => SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const Divider(height: 32),
              Text(
                post.content,
                style: const TextStyle(fontSize: 16, height: 1.6),
              ),
            ],
          ),
        ),
        _ => const SizedBox.shrink(),
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
