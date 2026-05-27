import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/settings/data/data_sources/remote/setting_api.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class SettingRepositoryImpl implements AbstractSettingRepository {
  final SettingApi _settingApi;
  SettingRepositoryImpl(this._settingApi);

  @override
  Future<Either<Failure, UserModel>> updateProfile(
    ProfileRequestModel request,
    UserModel user,
  ) async {
    try {
      final resposne = await _settingApi.updateProfile(request);
      final data = resposne.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final updatedUser = user.copyWith(
        profileImageUrl: data['profileImageUrl'],
      );
      return Right(updatedUser);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }
}
