import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

abstract class AbstractSettingRepository {
  Future<Either<Failure, UserModel>> updateProfile(
    ProfileRequestModel request,
    UserModel user,
  );
}
