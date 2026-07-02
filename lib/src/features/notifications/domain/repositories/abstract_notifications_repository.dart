import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';

abstract class AbstractNotificationsRepository {
  // Unit은 반환값이 없는 경우에 사용 (void와 유사)
  Future<Either<Failure, Unit>> registerFcmToken();

  Stream<String> get onTokenRefresh;
}
