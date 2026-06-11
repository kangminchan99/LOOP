import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/post/presentation/widgets/post_card_widget.dart';
import 'package:loop/src/shared/presentation/widgets/cursor_paginated_list_view.dart';

class BoardPage extends ConsumerWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(loginProvider) is LoginSuccess;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (!isLoggedIn) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('로그인 후 글 작성이 가능합니다.')));
            return;
          }
          await context.push(AppRoute.write.path);
          if (context.mounted) {
            ref.read(postListProvider.notifier).load();
          }
        },
        child: const Icon(Icons.edit),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          final state = ref.watch(postListProvider);

          ref.listen(postListProvider, (_, __) {});

          if (state.isLoading) return const CircularProgressIndicator();
          if (state.errorMessage != null && state.items.isEmpty) {
            return Center(child: Text(state.errorMessage!));
          }

          return CursorPaginatedListView<PostListModel>(
            items: state.items,
            hasNext: state.hasNext,
            isLoadingMore: state.isLoadingMore,
            onLoadMore: () => ref.read(postListProvider.notifier).loadMore(),
            itemBuilder: (context, post, index) => PostCardWidget(
              post: post,
              onTap: () => context.pushNamed(
                AppRoute.postDetail.name,
                pathParameters: {'postId': post.postId.toString()},
              ),
            ),
          );
        },
      ),
    );
  }
}
