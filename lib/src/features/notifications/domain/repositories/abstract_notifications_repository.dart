import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';

abstract class AbstractNotificationsRepository {
  // Unit은 반환값이 없는 경우에 사용 (void와 유사)
  Future<Either<Failure, Unit>> registerFcmToken();

  Future<Either<Failure, Unit>> deleteFcmToken();

  // 내 알림 목록 조회
  Future<Either<Failure, List<NotificationModel>>> getNotifications();

  // 읽지 않은 알림 개수 조회
  Future<Either<Failure, int>> getUnreadCount();

  // 알림 1개 읽음 처리
  Future<Either<Failure, NotificationModel>> markAsRead({
    required int notificationId,
  });

  // 전체 알림 읽음 처리
  Future<Either<Failure, Unit>> markAllAsRead();

  Stream<String> get onTokenRefresh;
}
