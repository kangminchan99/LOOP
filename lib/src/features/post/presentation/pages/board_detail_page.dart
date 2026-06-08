import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';

class BoardDetailPage extends ConsumerWidget {
  const BoardDetailPage({required this.postId, super.key});

  final int postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPost = ref.watch(postDetailProvider(postId));

    return DefaultLayout(
      appBarTitle: '게시글',
      child: asyncPost.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (post) => SingleChildScrollView(
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
      ),
    );
  }
}
