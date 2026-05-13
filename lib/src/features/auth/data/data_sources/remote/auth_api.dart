import 'package:dio/dio.dart';
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
}
