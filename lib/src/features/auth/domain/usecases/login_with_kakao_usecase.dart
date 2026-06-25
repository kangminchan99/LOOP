import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class LoginWithKakaoUsecase {
  const LoginWithKakaoUsecase({required AbstractAuthRepository authRepository})
    : _authRepository = authRepository;

  final AbstractAuthRepository _authRepository;

  Future<Either<Failure, UserModel>> call() {
    return _authRepository.loginWithKakao();
  }
}
