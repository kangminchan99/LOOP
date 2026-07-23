import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/comments/domain/models/my_comment_model.dart';
import 'package:loop/src/features/comments/presentation/providers/comment_provider.dart';
import 'package:loop/src/shared/presentation/widgets/cursor_paginated_list_view.dart';

class CommentListPage extends ConsumerWidget {
  const CommentListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myCommentsProvider);

    return DefaultLayout(
      appBarTitle: '내가 쓴 댓글',
      child: CursorPaginatedListView<MyCommentModel>(
        items: state.items,
        hasNext: state.hasNext,
        isLoadingMore: state.isLoadingMore,
        emptyWidget: const Center(child: Text('작성한 댓글이 없습니다.')),
        onLoadMore: () {
          ref.read(myCommentsProvider.notifier).loadMore();
        },
        itemBuilder: (context, comment, index) {
          return ListTile(
            title: Text(
              comment.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  comment.postTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  Helpers().formatDate(comment.createdAt),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.pushNamed(
                AppRoute.postDetail.name,
                pathParameters: {'postId': comment.postId.toString()},
              );
            },
          );
        },
      ),
    );
  }
}
