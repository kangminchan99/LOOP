import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';

class MarkNotificationAsReadUseCase {
  const MarkNotificationAsReadUseCase(this._repository);

  final AbstractNotificationsRepository _repository;

  Future<Either<Failure, NotificationModel>> call({
    required int notificationId,
  }) {
    return _repository.markAsRead(notificationId: notificationId);
  }
}
