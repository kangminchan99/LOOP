import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  const MarkAllNotificationsAsReadUseCase(this._repository);

  final AbstractNotificationsRepository _repository;

  Future<Either<Failure, Unit>> call() {
    return _repository.markAllAsRead();
  }
}
