// 페이지네이션 공통 모델
class CursorPaginatedResponse<T> {
  const CursorPaginatedResponse({
    required this.items,
    required this.hasNext,
    this.nextCursor,
  });

  final List<T> items;
  final int? nextCursor;
  final bool hasNext;

  factory CursorPaginatedResponse.fromJson({
    required Map<String, dynamic> json,
    required T Function(Map<String, dynamic>) itemParser,
  }) {
    return CursorPaginatedResponse(
      items: (json['items'] as List)
          .map((e) => itemParser(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool,
      nextCursor: json['nextCursor'] as int?,
    );
  }
}
