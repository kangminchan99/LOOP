import 'package:flutter/material.dart';
import 'package:loop/src/core/utils/helpers/initializer.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';

class CommentItemWidget extends StatelessWidget {
  const CommentItemWidget({
    required this.comment,
    required this.myId,
    required this.onDeleteTap,
    super.key,
  });

  final CommentModel comment;
  final int? myId;
  final VoidCallback onDeleteTap;

  bool get _isMine => myId != null && comment.authorId == myId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            child: Text(
              comment.authorNickname.isNotEmpty
                  ? comment.authorNickname[0]
                  : '?',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorNickname,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Helpers().formatDate(comment.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    const Spacer(),
                    if (_isMine)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: onDeleteTap,
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.content,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
