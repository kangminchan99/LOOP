import 'package:dio/dio.dart';
import 'package:loop/src/features/post/domain/models/create_post_request_model.dart';

class PostApi {
  final Dio _dio;

  PostApi(this._dio);

  Future<Response<Map<String, dynamic>>> createPost(
    CreatePostRequestModel requset,
  ) {
    return _dio.post<Map<String, dynamic>>('/posts', data: requset.toJson());
  }

  Future<Response<Map<String, dynamic>>> getPosts({
    int limit = 20,
    int? cursor,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/posts',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
    );
  }

  Future<Response<Map<String, dynamic>>> getPostById(int postId) {
    return _dio.get<Map<String, dynamic>>('/posts/$postId');
  }

  Future<Response<void>> deletePost(int postId) {
    return _dio.delete<void>('/posts/$postId');
  }
}
