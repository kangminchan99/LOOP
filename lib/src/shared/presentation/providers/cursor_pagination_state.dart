class CursorPaginationState<T> {
  const CursorPaginationState({
    this.items = const [],
    this.nextCursor,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasNext;
  final bool isLoading; // 첫 로드
  final bool isLoadingMore; // 추가 로드
  final String? errorMessage;

  CursorPaginationState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
  }) {
    return CursorPaginationState<T>(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
    );
  }
}
