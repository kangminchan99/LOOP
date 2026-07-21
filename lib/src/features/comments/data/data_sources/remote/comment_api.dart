import 'package:dio/dio.dart';
import 'package:loop/src/features/comments/domain/models/comment_request_model.dart';

class CommentApi {
  final Dio _dio;

  CommentApi(this._dio);

  Future<Response<Map<String, dynamic>>> getComments({
    required int postId,
    int limit = 20,
    String? cursor,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/posts/$postId/comments',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
  }

  Future<Response<Map<String, dynamic>>> createComment({
    required int postId,
    required CommentRequestModel request,
  }) {
    return _dio.post<Map<String, dynamic>>(
      '/posts/$postId/comments',
      data: request.toJson(),
    );
  }

  Future<Response<void>> deleteComment({
    required int postId,
    required int commentId,
  }) {
    return _dio.delete<void>('/posts/$postId/comments/$commentId');
  }
}
