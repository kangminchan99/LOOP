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

  // 내 알림 목록 조회
  Future<Response<List<dynamic>>> getNotifications() {
    return _dio.get<List<dynamic>>('/notifications');
  }

  // 읽지 않은 알림 개수 조회
  Future<Response<Map<String, dynamic>>> getUnreadCount() {
    return _dio.get<Map<String, dynamic>>('/notifications/unread-count');
  }

  // 알림 1개 읽음 처리
  Future<Response<Map<String, dynamic>>> markAsRead({
    required int notificationId,
  }) {
    return _dio.patch<Map<String, dynamic>>(
      '/notifications/$notificationId/read',
    );
  }

  // 전체 알림 읽음 처리
  Future<Response<Map<String, dynamic>>> markAllAsRead() {
    return _dio.patch<Map<String, dynamic>>('/notifications/read-all');
  }
}
