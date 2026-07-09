import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/notifications/data/data_sources/local/fcm_token_data_source.dart';
import 'package:loop/src/features/notifications/data/data_sources/remote/notifications_api.dart';
import 'package:loop/src/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:loop/src/features/notifications/domain/repositories/abstract_notifications_repository.dart';
import 'package:loop/src/features/notifications/domain/usecases/delete_fcm_token_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/get_unread_count_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:loop/src/features/notifications/domain/usecases/register_fcm_token_usecase.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_notifier.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_state.dart';

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

final deleteFcmTokenUseCaseProvider = Provider<DeleteFcmTokenUseCase>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);

  return DeleteFcmTokenUseCase(notificationsRepository: repository);
});

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  final repository = ref.watch(notificationsRepositoryProvider);

  return GetNotificationsUseCase(repository);
});

final getUnreadCountUseCaseProvider = Provider<GetUnreadCountUseCase>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);

  return GetUnreadCountUseCase(repository);
});

final markNotificationAsReadUseCaseProvider =
    Provider<MarkNotificationAsReadUseCase>((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);

      return MarkNotificationAsReadUseCase(repository);
    });

final markAllNotificationsAsReadUseCaseProvider =
    Provider<MarkAllNotificationsAsReadUseCase>((ref) {
      final repository = ref.watch(notificationsRepositoryProvider);

      return MarkAllNotificationsAsReadUseCase(repository);
    });

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
      final getNotificationsUseCase = ref.watch(
        getNotificationsUseCaseProvider,
      );
      final getUnreadCountUseCase = ref.watch(getUnreadCountUseCaseProvider);
      final markNotificationAsReadUseCase = ref.watch(
        markNotificationAsReadUseCaseProvider,
      );
      final markAllNotificationsAsReadUseCase = ref.watch(
        markAllNotificationsAsReadUseCaseProvider,
      );

      return NotificationNotifier(
        getNotificationsUseCase: getNotificationsUseCase,
        getUnreadCountUseCase: getUnreadCountUseCase,
        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
        markAllNotificationsAsReadUseCase: markAllNotificationsAsReadUseCase,
      );
    });
