import 'package:dio/dio.dart';

class UserBlocksApi {
  const UserBlocksApi(this._dio);

  final Dio _dio;

  static const _basePath = '/users/me/blocks';

  // 상세 화면의 authorId를 targetUserId로 전달한다.
  Future<Response<Map<String, dynamic>>> blockUser({
    required int targetUserId,
  }) {
    return _dio.put<Map<String, dynamic>>('$_basePath/$targetUserId');
  }

  // 성공 응답은 204이므로 본문을 읽지 않는다.
  Future<void> unblockUser({required int targetUserId}) async {
    await _dio.delete<void>('$_basePath/$targetUserId');
  }

  Future<Response<Map<String, dynamic>>> getBlockedUsers({
    int limit = 20,
    String? cursor,
    CancelToken? cancelToken,
  }) {
    return _dio.get<Map<String, dynamic>>(
      _basePath,
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      cancelToken: cancelToken,
    );
  }
}
