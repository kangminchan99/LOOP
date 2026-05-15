import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/models/sign_up_request_model.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

abstract class AbstractAuthRepository {
  Future<Either<Failure, UserModel>> signUp(SignUpRequestModel request);

  Future<Either<Failure, UserModel>> login(LoginRequestModel request);
}
