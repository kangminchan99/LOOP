import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/max_width_container.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/presentation/providers/post_providers.dart';
import 'package:loop/src/features/post/presentation/widgets/post_card_widget.dart';
import 'package:loop/src/shared/presentation/widgets/cursor_paginated_list_view.dart';

class BoardPage extends ConsumerStatefulWidget {
  const BoardPage({super.key});

  @override
  ConsumerState<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends ConsumerState<BoardPage> {
  final _searchController = TextEditingController();

  Timer? _debounce;

  bool get _hasSearchText => _searchController.text.trim().isNotEmpty;
  bool _isSearchMode = false;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});

    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final keyword = value.trim();

      if (keyword.isEmpty) {
        ref.read(searchPostProvider.notifier).clear();

        if (!mounted) return;

        setState(() {
          _isSearchMode = false;
          _hasSearched = false;
        });

        return;
      }

      setState(() {
        _isSearchMode = true;
      });

      await ref.read(searchPostProvider.notifier).search(keyword);

      if (!mounted) return;

      setState(() {
        _hasSearched = true;
      });
    });
  }

  void _clearSearch() {
    _debounce?.cancel();
    _searchController.clear();
    ref.read(searchPostProvider.notifier).clear();
    setState(() {
      _isSearchMode = false;
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final isLoggedIn = ref.watch(loginProvider) is LoginSuccess;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: '게시글 검색',
            border: InputBorder.none,
          ),
          textInputAction: TextInputAction.search,
          onChanged: _onSearchChanged,
        ),
        actions: [
          if (_hasSearchText)
            IconButton(icon: const Icon(Icons.close), onPressed: _clearSearch),
        ],
      ),
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
      body: MaxWidthContainer(
        maxWidth: 720,
        child: Consumer(
          builder: (context, ref, _) {
            final normalState = ref.watch(postListProvider);
            final searchState = ref.watch(searchPostProvider);

            final state = _isSearchMode && _hasSearched
                ? searchState
                : normalState;

            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.errorMessage != null && state.items.isEmpty) {
              return Center(child: Text(state.errorMessage!));
            }

            return CursorPaginatedListView<PostListModel>(
              items: state.items,
              hasNext: state.hasNext,
              isLoadingMore: state.isLoadingMore,
              emptyWidget: Center(
                child: Text(_isSearchMode ? '검색 결과가 없습니다.' : '게시글이 없습니다.'),
              ),
              onLoadMore: () {
                if (_isSearchMode) {
                  ref.read(searchPostProvider.notifier).loadMore();
                  return;
                }

                ref.read(postListProvider.notifier).loadMore();
              },
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
      ),
    );
  }
}
