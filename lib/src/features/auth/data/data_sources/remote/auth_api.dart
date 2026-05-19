import 'package:dio/dio.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/models/sign_up_request_model.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<Response<Map<String, dynamic>>> signUp(SignUpRequestModel request) {
    return _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
  }

  Future<Response<Map<String, dynamic>>> login(LoginRequestModel request) {
    return _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
  }

  Future<Response<Map<String, dynamic>>> getMe() {
    return _dio.get<Map<String, dynamic>>('/users/me');
  }
}
