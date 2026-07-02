import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/notifications/data/data_sources/local/fcm_token_data_source.dart';
import 'package:loop/src/features/notifications/data/data_sources/remote/notifications_api.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';

class NotificationsRepositoryImpl implements AbstractNotificationsRepository {
  const NotificationsRepositoryImpl({
    required FcmTokenDataSource fcmTokenDataSource,
    required NotificationsApi notificationsApi,
  }) : _fcmTokenDataSource = fcmTokenDataSource,
       _notificationsApi = notificationsApi;

  final FcmTokenDataSource _fcmTokenDataSource;
  final NotificationsApi _notificationsApi;

  @override
  Future<Either<Failure, Unit>> registerFcmToken() async {
    try {
      await _fcmTokenDataSource.requestPermission();

      final token = await _fcmTokenDataSource.getToken();

      if (token == null || token.isEmpty) {
        return const Left(ServerFailure('FCM 토큰을 가져올 수 없습니다.', null));
      }

      await _notificationsApi.registerFcmToken(
        token: token,
        platform: _fcmTokenDataSource.platform,
      );

      return const Right(unit);
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Stream<String> get onTokenRefresh => _fcmTokenDataSource.onTokenRefresh;
}
