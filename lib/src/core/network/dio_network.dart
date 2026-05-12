import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loop/src/core/network/interceptors/logger_interceptor.dart';
import 'package:loop/src/core/utils/log/app_logger.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';

class DioNetwork {
  static late Dio appAPI;
  static late Dio retryAPI;

  static late FlutterSecureStorage _secureStorage;

  static void initDio(FlutterSecureStorage storage) {
    _secureStorage = storage;
    appAPI = Dio(_baseOptions(apiUrl));
    appAPI.interceptors.add(_loggerInterceptor());
    appAPI.interceptors.add(_authQueuedInterceptor());

    retryAPI = Dio(_baseOptions(apiUrl));
    retryAPI.interceptors.add(_loggerInterceptor());
  }

  static LoggerInterceptor _loggerInterceptor() {
    return LoggerInterceptor(
      logger,
      request: true,
      requestBody: true,
      error: true,
      responseBody: true,
      responseHeader: false,
      requestHeader: true,
    );
  }

  /// AccessToken 자동 주입 + 401 시 자동 갱신하는 큐 인터셉터.
  /// Queue 방식으로 동시 요청 중 토큰 갱신이 중복 실행되지 않도록 보장.
  static QueuedInterceptorsWrapper _authQueuedInterceptor() {
    return QueuedInterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: kAccessTokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },

      onError: (error, handler) async {
        // 401이고 /auth/refresh 요청 자체가 아닌 경우에만 갱신 시도
        final isUnauthorized = error.response?.statusCode == 401;
        final isRefreshRequest = error.requestOptions.path == '/auth/refresh';

        if (isUnauthorized && !isRefreshRequest) {
          try {
            final newToken = await _tryRefreshToken();
            if (newToken != null) {
              // 새 토큰으로 원래 요청 재시도
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer $newToken';
              final response = await appAPI.fetch(opts);
              return handler.resolve(response);
            }
          } catch (_) {
            // RefreshToken까지 만료 → 저장된 토큰 전부 삭제
            // AuthCubit의 getMe() 최종 실패 시 로그아웃 처리까지 연결됨
            await _secureStorage.delete(key: kAccessTokenKey);
            await _secureStorage.delete(key: kRefreshTokenKey);
          }
        }
        return handler.next(error);
      },

      onResponse: (response, handler) => handler.next(response),
    );
  }

  /// retryAPI로 RefreshToken → 새 AccessToken 발급 후 SecureStorage에 저장.
  static Future<String?> _tryRefreshToken() async {
    final refreshToken = await _secureStorage.read(key: kRefreshTokenKey);
    if (refreshToken == null) return null;

    final response = await retryAPI.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );

    final newToken = response.data?['accessToken'] as String?;
    if (newToken != null) {
      await _secureStorage.write(key: kAccessTokenKey, value: newToken);
    }
    return newToken;
  }

  static BaseOptions _baseOptions(String url) {
    return BaseOptions(
      baseUrl: url,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      validateStatus: (status) =>
          status != null && status >= 200 && status < 300,
      responseType: ResponseType.json,
    );
  }
}
