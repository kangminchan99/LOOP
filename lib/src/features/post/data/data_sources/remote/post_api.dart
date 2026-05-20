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
}
