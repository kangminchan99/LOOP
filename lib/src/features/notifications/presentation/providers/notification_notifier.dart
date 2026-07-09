import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';
import 'package:loop/src/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_state.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier({
    required GetNotificationsUseCase getNotificationsUseCase,
    required GetUnreadCountUseCase getUnreadCountUseCase,
    required MarkNotificationAsReadUseCase markNotificationAsReadUseCase,
    required MarkAllNotificationsAsReadUseCase
    markAllNotificationsAsReadUseCase,
  }) : _getNotificationsUseCase = getNotificationsUseCase,
       _getUnreadCountUseCase = getUnreadCountUseCase,
       _markNotificationAsReadUseCase = markNotificationAsReadUseCase,
       _markAllNotificationsAsReadUseCase = markAllNotificationsAsReadUseCase,
       super(const NotificationState.initial());

  final GetNotificationsUseCase _getNotificationsUseCase;
  final GetUnreadCountUseCase _getUnreadCountUseCase;
  final MarkNotificationAsReadUseCase _markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase _markAllNotificationsAsReadUseCase;

  Future<void> loadNotifications() async {
    state = const NotificationState.loading();

    final notificationsResult = await _getNotificationsUseCase();
    final unreadCountResult = await _getUnreadCountUseCase();

    notificationsResult.match(
      (failure) {
        state = NotificationState.failure(message: failure.errorMessage);
      },
      (notifications) {
        final unreadCount = unreadCountResult.match(
          (_) => notifications
              .where((notification) => notification.readAt == null)
              .length,
          (count) => count,
        );

        state = NotificationState.success(
          notifications: notifications,
          unreadCount: unreadCount,
        );
      },
    );
  }

  Future<void> markAsRead({required NotificationModel notification}) async {
    if (notification.readAt != null) {
      return;
    }

    final result = await _markNotificationAsReadUseCase(
      notificationId: notification.id,
    );

    result.match(
      (failure) {
        state = NotificationState.failure(message: failure.errorMessage);
      },
      (updatedNotification) {
        final currentState = state;

        if (currentState is! NotificationSuccess) {
          return;
        }

        final updatedNotifications = currentState.notifications.map((item) {
          if (item.id == updatedNotification.id) {
            return updatedNotification;
          }

          return item;
        }).toList();

        final unreadCount = updatedNotifications
            .where((item) => item.readAt == null)
            .length;

        state = NotificationState.success(
          notifications: updatedNotifications,
          unreadCount: unreadCount,
        );
      },
    );
  }

  Future<void> markAllAsRead() async {
    final currentState = state;

    if (currentState is! NotificationSuccess) {
      return;
    }

    final result = await _markAllNotificationsAsReadUseCase();

    result.match(
      (failure) {
        state = NotificationState.failure(message: failure.errorMessage);
      },
      (_) {
        final now = DateTime.now();

        final updatedNotifications = currentState.notifications.map((item) {
          return item.copyWith(readAt: item.readAt ?? now);
        }).toList();

        state = NotificationState.success(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      },
    );
  }
}
