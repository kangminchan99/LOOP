import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

abstract class AbstractPostRepository {
  Future<Either<Failure, PostDetailModel>> createPost(PostRequestModel request);

  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> getPosts({
    String? cursor,
  });

  Future<Either<Failure, PostDetailModel>> getPostById(int postId);

  Future<Either<Failure, void>> deletePost(int postId);

  Future<Either<Failure, PostDetailModel>> updatePost(
    int postId,
    PostRequestModel request,
  );

  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> searchPosts({
    required String keyword,
    String? cursor,
  });

  // 유효기간이 남은 캐시 목록 조회.
  Future<Either<Failure, List<PostListModel>>> getCachedPosts();

  // 서버에서 처음부터 연속으로 조회한 목록 저장.
  Future<Either<Failure, void>> savePostsCache(List<PostListModel> freshPosts);

  // 로그아웃·계정 변경 시 캐시 삭제.
  Future<Either<Failure, void>> clearPostsCache();
}
