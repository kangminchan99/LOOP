import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/domain/models/notification_model.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';

class GetNotificationsUseCase {
  const GetNotificationsUseCase(this._repository);

  final AbstractNotificationsRepository _repository;

  Future<Either<Failure, List<NotificationModel>>> call() {
    return _repository.getNotifications();
  }
}
