import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
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
}
