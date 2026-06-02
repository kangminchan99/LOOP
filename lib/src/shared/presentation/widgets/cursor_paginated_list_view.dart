import 'package:flutter/material.dart';

class CursorPaginatedListView<T> extends StatefulWidget {
  const CursorPaginatedListView({
    required this.items,
    required this.itemBuilder,
    required this.onLoadMore,
    required this.hasNext,
    this.isLoadingMore = false,
    this.errorMessage,
    this.separatorBuilder,
    this.emptyWidget,
    super.key,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final VoidCallback onLoadMore;
  final bool hasNext;
  final bool isLoadingMore;
  final String? errorMessage;
  final Widget Function(BuildContext, int)? separatorBuilder;
  final Widget? emptyWidget;

  @override
  State<CursorPaginatedListView<T>> createState() =>
      _CursorPaginatedListViewState<T>();
}

class _CursorPaginatedListViewState<T>
    extends State<CursorPaginatedListView<T>> {
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200 &&
        widget.hasNext &&
        !widget.isLoadingMore) {
      widget.onLoadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return widget.emptyWidget ?? const SizedBox.shrink();
    }
    return ListView.separated(
      controller: _scrollController,
      itemCount: widget.items.length + (widget.isLoadingMore ? 1 : 0),
      separatorBuilder:
          widget.separatorBuilder ?? (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        if (index == widget.items.length) {
          // 하단 로딩 인디케이터
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return widget.itemBuilder(context, widget.items[index], index);
      },
    );
  }
}
