import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
      final settings = await _fcmTokenDataSource.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return const Left(ServerFailure('알림 권한이 거부되었습니다.', null));
      }

      if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
        return const Left(ServerFailure('알림 권한이 아직 결정되지 않았습니다.', null));
      }

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
  Future<Either<Failure, Unit>> deleteFcmToken() async {
    try {
      final token = await _fcmTokenDataSource.getToken();

      if (token == null || token.isEmpty) {
        return const Right(unit);
      }

      await _notificationsApi.deleteFcmToken(token: token);

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
