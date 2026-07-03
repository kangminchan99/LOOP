import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';

class DeleteFcmTokenUseCase {
  const DeleteFcmTokenUseCase({
    required AbstractNotificationsRepository notificationsRepository,
  }) : _notificationsRepository = notificationsRepository;

  final AbstractNotificationsRepository _notificationsRepository;

  Future<Either<Failure, Unit>> call() {
    return _notificationsRepository.deleteFcmToken();
  }
}
