import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/presentation/providers/post_detail/post_detail_state.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';

class BoardEditPage extends ConsumerStatefulWidget {
  const BoardEditPage({super.key, required this.postId});

  final int postId;

  @override
  ConsumerState<BoardEditPage> createState() => _BoardEditPageState();
}

class _BoardEditPageState extends ConsumerState<BoardEditPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _initialized = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postDetailProvider(widget.postId));

    ref.listen(postDetailProvider(widget.postId), (_, next) {
      if (!_isSubmitted) return;

      if (next is PostDetailSuccess) {
        ref.read(postListProvider.notifier).load();

        if (context.mounted) {
          context.pop();
        }
      }

      if (next is PostDetailError) {
        _isSubmitted = false;

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.message)));
      }
    });

    if (state is PostDetailSuccess && !_initialized) {
      _titleController.text = state.post.title;
      _contentController.text = state.post.content;
      _initialized = true;
    }

    return DefaultLayout(
      appBarTitle: '게시글 수정',
      actions: [
        TextButton(
          onPressed: () {
            _isSubmitted = true;

            ref
                .read(postDetailProvider(widget.postId).notifier)
                .update(
                  PostRequestModel(
                    title: _titleController.text,
                    content: _contentController.text,
                  ),
                );
          },
          child: const Text('완료'),
        ),
      ],
      child: switch (state) {
        PostDetailLoading() => const Center(child: CircularProgressIndicator()),
        PostDetailSuccess() => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(hintText: '제목'),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TextField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  decoration: const InputDecoration(hintText: '내용'),
                ),
              ),
            ],
          ),
        ),
        PostDetailError(:final message) => Center(child: Text(message)),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
