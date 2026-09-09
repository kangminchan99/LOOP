class CursorPaginationState<T> {
  const CursorPaginationState({
    this.items = const [],
    this.nextCursor,
    this.hasNext = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.errorMessage,
    this.isFromCache = false,
    this.isOffline = false,
  });

  final List<T> items;
  final String? nextCursor;
  final bool hasNext;
  final bool isLoading; // 첫 로드
  final bool isLoadingMore; // 추가 로드
  final String? errorMessage;
  final bool isFromCache;
  final bool isOffline;

  CursorPaginationState<T> copyWith({
    List<T>? items,
    String? nextCursor,
    bool? hasNext,
    bool? isLoading,
    bool? isLoadingMore,
    String? errorMessage,
    bool? isFromCache,
    bool? isOffline,
  }) {
    return CursorPaginationState<T>(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasNext: hasNext ?? this.hasNext,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
