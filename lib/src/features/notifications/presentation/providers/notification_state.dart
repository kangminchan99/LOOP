import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState.initial() = NotificationInitial;

  const factory NotificationState.loading() = NotificationLoading;

  const factory NotificationState.success({
    required List<NotificationModel> notifications,
    required int unreadCount,
  }) = NotificationSuccess;

  const factory NotificationState.failure({required String message}) =
      NotificationFailure;
}
