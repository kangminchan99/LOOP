import 'package:dio/dio.dart';

class NotificationsApi {
  const NotificationsApi(this._dio);

  final Dio _dio;

  Future<Response<Map<String, dynamic>>> registerFcmToken({
    required String token,
    required String platform,
  }) {
    return _dio.post<Map<String, dynamic>>(
      '/notifications/fcm-token',
      data: {'token': token, 'platform': platform},
    );
  }

  // 알림 삭제
  Future<Response<Map<String, dynamic>>> deleteFcmToken({
    required String token,
  }) {
    return _dio.delete<Map<String, dynamic>>(
      '/notifications/fcm-token',
      data: {'token': token},
    );
  }
}
