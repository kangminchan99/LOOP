// 피쳐별 페이지네이션을 위해 추상 클래스로 구현
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';
import 'package:loop/src/shared/presentation/providers/cursor_pagination_state.dart';

abstract class CursorPaginationNotifier<T>
    extends StateNotifier<CursorPaginationState<T>> {
  CursorPaginationNotifier() : super(const CursorPaginationState());

  // 각 피쳐에서 구현 - cursor가 null이면 첫 페이지
  Future<Either<Failure, CursorPaginatedResponse<T>>> fetchPage(int? curosr);

  // 첫 로딩
  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await fetchPage(null);
    result.match(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.errorMessage,
      ),
      (data) => state = CursorPaginationState<T>(
        items: data.items,
        nextCursor: data.nextCursor,
        hasNext: data.hasNext,
      ),
    );
  }

  // 추가 로드 (무한스크롤)
  Future<void> loadMore() async {
    if (state.isLoadingMore || state.isLoading) return;
    if (!state.hasNext || state.nextCursor == null) return;

    state = state.copyWith(isLoadingMore: true, errorMessage: null);

    final result = await fetchPage(state.nextCursor);
    result.match(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        errorMessage: failure.errorMessage,
      ),
      (data) => state = state.copyWith(
        items: [...state.items, ...data.items],
        nextCursor: data.nextCursor,
        hasNext: data.hasNext,
        isLoadingMore: false,
      ),
    );
  }
}
