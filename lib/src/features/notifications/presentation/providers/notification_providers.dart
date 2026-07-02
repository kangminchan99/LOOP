import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/notifications/data/data_sources/local/fcm_token_data_source.dart';
import 'package:loop/src/features/notifications/data/data_sources/remote/notifications_api.dart';
import 'package:loop/src/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';
import 'package:loop/src/features/notifications/domain/usecases/register_fcm_token_usecase.dart';

final fcmTokenDataSourceProvider = Provider<FcmTokenDataSource>((ref) {
  return FcmTokenDataSource();
});

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsApi(dio);
});

final notificationsRepositoryProvider =
    Provider<AbstractNotificationsRepository>((ref) {
      final fcmTokenDataSource = ref.watch(fcmTokenDataSourceProvider);
      final notificationsApi = ref.watch(notificationsApiProvider);

      return NotificationsRepositoryImpl(
        fcmTokenDataSource: fcmTokenDataSource,
        notificationsApi: notificationsApi,
      );
    });

final registerFcmTokenUseCaseProvider = Provider<RegisterFcmTokenUseCase>((
  ref,
) {
  final repository = ref.watch(notificationsRepositoryProvider);

  return RegisterFcmTokenUseCase(notificationsRepository: repository);
});
