import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/comments/data/data_sources/remote/comment_api.dart';
import 'package:loop/src/features/comments/domain/models/comment_model.dart';
import 'package:loop/src/features/comments/domain/models/comment_request_model.dart';
import 'package:loop/src/features/comments/domain/models/my_comment_model.dart';
import 'package:loop/src/features/comments/domain/repositories/abstract_comment_repository.dart';
import 'package:loop/src/shared/domain/models/cursor_paginated_response.dart';

class CommentRepositoryImpl implements AbstractCommentRepository {
  final CommentApi _commentApi;

  CommentRepositoryImpl(this._commentApi);

  @override
  Future<Either<Failure, CursorPaginatedResponse<CommentModel>>> getComments({
    required int postId,
    String? cursor,
  }) async {
    try {
      final response = await _commentApi.getComments(
        postId: postId,
        cursor: cursor,
      );

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(
        CursorPaginatedResponse.fromJson(
          json: data,
          itemParser: (e) => CommentModel.fromJson(e),
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
  Future<Either<Failure, CommentModel>> createComment({
    required int postId,
    required CommentRequestModel request,
  }) async {
    try {
      final response = await _commentApi.createComment(
        postId: postId,
        request: request,
      );

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(CommentModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, void>> deleteComment({
    required int postId,
    required int commentId,
  }) async {
    try {
      await _commentApi.deleteComment(postId: postId, commentId: commentId);

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
  Future<Either<Failure, CursorPaginatedResponse<MyCommentModel>>>
  getMyComments({String? cursor}) async {
    try {
      final response = await _commentApi.getMyComments(cursor: cursor);

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(
        CursorPaginatedResponse.fromJson(
          json: data,
          itemParser: (e) => MyCommentModel.fromJson(e),
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
