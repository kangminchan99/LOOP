import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/post/data/data_sources/remote/post_api.dart';
import 'package:loop/src/features/post/domain/models/post_response_model.dart';
import 'package:loop/src/features/post/domain/models/post_detail_model.dart';
import 'package:loop/src/features/post/domain/models/post_list_model.dart';
import 'package:loop/src/features/post/domain/models/post_request_model.dart';
import 'package:loop/src/features/post/domain/repositories/abstract_post_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class PostRepositoryImpl implements AbstractPostRepository {
  final PostApi _postApi;
  PostRepositoryImpl(this._postApi);

  @override
  Future<Either<Failure, PostDetailModel>> createPost(
    PostRequestModel request,
  ) async {
    try {
      final response = await _postApi.createPost(request);

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = PostResponseModel.fromJson(data);

      return Right(
        PostDetailModel(
          id: parsed.id,
          title: parsed.title,
          content: parsed.content,
          authorId: parsed.authorId,
          updatedAt: parsed.updatedAt,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, CursorPaginatedResponse<PostListModel>>> getPosts({
    int? cursor,
  }) async {
    try {
      final response = await _postApi.getPosts(cursor: cursor);
      final data = response.data;
      if (data == null) return const Left(ServerFailure('응답 데이터가 없습니다.', 500));

      return Right(
        CursorPaginatedResponse.fromJson(
          json: data,
          itemParser: (e) => PostListModel.fromJson(e),
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, PostDetailModel>> getPostById(int postId) async {
    try {
      final response = await _postApi.getPostById(postId);
      final data = response.data;
      if (data == null) return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      return Right(PostDetailModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, void>> deletePost(int postId) async {
    try {
      await _postApi.deletePost(postId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, PostDetailModel>> updatePost(
    int postId,
    PostRequestModel request,
  ) async {
    try {
      final response = await _postApi.updatePost(postId, request);

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = PostResponseModel.fromJson(data);

      return Right(
        PostDetailModel(
          id: parsed.id,
          title: parsed.title,
          content: parsed.content,
          authorId: parsed.authorId,
          updatedAt: parsed.updatedAt,
        ),
      );
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }
}
