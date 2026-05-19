import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:loop/src/features/auth/data/data_sources/remote/auth_api.dart';
import 'package:loop/src/features/auth/domain/models/auth_response_model.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/models/sign_up_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class AuthRepositoryImpl implements AbstractAuthRepository {
  final AuthApi _authApi;
  final FlutterSecureStorage _secureStorage;
  AuthRepositoryImpl(this._authApi, this._secureStorage);
  @override
  Future<Either<Failure, UserModel>> signUp(SignUpRequestModel request) async {
    try {
      final response = await _authApi.signUp(request);
      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = AuthResponseModel.fromJson(data);

      await _secureStorage.write(
        key: kAccessTokenKey,
        value: parsed.accessToken,
      );
      await _secureStorage.write(
        key: kRefreshTokenKey,
        value: parsed.refreshToken,
      );

      return Right(parsed.user);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, UserModel>> login(LoginRequestModel request) async {
    try {
      final response = await _authApi.login(request);
      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      final parsed = AuthResponseModel.fromJson(data);

      await _secureStorage.write(
        key: kAccessTokenKey,
        value: parsed.accessToken,
      );

      await _secureStorage.write(
        key: kRefreshTokenKey,
        value: parsed.refreshToken,
      );

      return Right(parsed.user);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<void> logout() async {
    await _secureStorage.delete(key: kAccessTokenKey);
    await _secureStorage.delete(key: kRefreshTokenKey);
  }

  @override
  Future<Either<Failure, UserModel>> getMe() async {
    try {
      final response = await _authApi.getMe();
      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(UserModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }
}
