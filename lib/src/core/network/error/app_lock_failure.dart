import 'package:loop/src/core/network/error/failures.dart';

// 화면에서 구분해서 처리할 생체 인증 오류
enum AppLockFailureCode {
  unsupported,
  notEnrolled,
  temporarilyUnavailable,
  temporaryLockout,
  biometricLockout,
  authenticationInProgress,
  fallbackRequested,
  unknown,
}

class AppLockFailure extends Failure {
  final AppLockFailureCode code;

  const AppLockFailure({required this.code, required String message})
    : super(message);

  @override
  List<Object?> get props => [code, errorMessage];
}
