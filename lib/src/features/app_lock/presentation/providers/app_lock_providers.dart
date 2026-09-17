import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/app_lock/data/data_sources/local/app_lock_settings_local_data_source.dart';
import 'package:loop/src/features/app_lock/domain/usecases/authenticate_app_lock_usecase.dart';
import 'package:loop/src/features/app_lock/domain/usecases/change_app_lock_setting_usecase.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_notifier.dart';
import 'package:loop/src/features/app_lock/presentation/providers/app_lock_state.dart';

import '../../data/data_sources/local/biometric_local_data_source.dart';
import '../../data/repositories/app_lock_repository_impl.dart';
import '../../domain/repositories/abstract_app_lock_repository.dart';

final appLockSettingsLocalDataSourceProvider =
    Provider<AppLockSettingsLocalDataSource>((ref) {
      final storage = ref.watch(secureStorageProvider);

      return AppLockSettingsLocalDataSource(storage);
    });

// OS 생체 인증 기능을 호출하는 객체
final localAuthenticationProvider = Provider<LocalAuthentication>((ref) {
  return LocalAuthentication();
});

// 플러그인을 감싸는 DataSource
final biometricLocalDataSourceProvider = Provider<BiometricLocalDataSource>((
  ref,
) {
  final auth = ref.watch(localAuthenticationProvider);

  return BiometricLocalDataSource(auth);
});

// 상위 계층에는 추상 Repository로 제공
final appLockRepositoryProvider = Provider<AbstractAppLockRepository>((ref) {
  final dataSource = ref.watch(biometricLocalDataSourceProvider);
  final settingsDataSource = ref.watch(appLockSettingsLocalDataSourceProvider);

  return AppLockRepositoryImpl(dataSource, settingsDataSource);
});

final authenticateAppLockUseCaseProvider = Provider<AuthenticateAppLockUseCase>(
  (ref) {
    final repository = ref.watch(appLockRepositoryProvider);

    return AuthenticateAppLockUseCase(repository);
  },
);

final changeAppLockSettingUseCaseProvider =
    Provider<ChangeAppLockSettingUseCase>((ref) {
      final repository = ref.watch(appLockRepositoryProvider);
      final authenticate = ref.watch(authenticateAppLockUseCaseProvider);

      return ChangeAppLockSettingUseCase(repository, authenticate);
    });

final appLockProvider = StateNotifierProvider<AppLockNotifier, AppLockState>((
  ref,
) {
  final repository = ref.watch(appLockRepositoryProvider);
  final authenticate = ref.watch(authenticateAppLockUseCaseProvider);
  final changeSetting = ref.watch(changeAppLockSettingUseCaseProvider);

  return AppLockNotifier(repository, authenticate, changeSetting);
});
