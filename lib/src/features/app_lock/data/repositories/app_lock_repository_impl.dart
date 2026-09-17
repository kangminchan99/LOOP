import 'package:fpdart/fpdart.dart';
import 'package:local_auth/local_auth.dart';
import 'package:loop/src/core/network/error/app_lock_failure.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/app_lock/data/data_sources/local/app_lock_settings_local_data_source.dart';

import '../../domain/models/biometric_capability_model.dart';
import '../../domain/repositories/abstract_app_lock_repository.dart';
import '../data_sources/local/biometric_local_data_source.dart';

class AppLockRepositoryImpl implements AbstractAppLockRepository {
  final BiometricLocalDataSource _dataSource;
  final AppLockSettingsLocalDataSource _settingsDataSource;

  AppLockRepositoryImpl(this._dataSource, this._settingsDataSource);

  @override
  Future<Either<Failure, BiometricCapabilityModel>>
  getBiometricCapability() async {
    try {
      final capability = await _dataSource.getBiometricCapability();
      return Right(capability);
    } on LocalAuthException catch (e) {
      return Left(_mapException(e));
    } catch (_) {
      return const Left(
        AppLockFailure(
          code: AppLockFailureCode.unknown,
          message: '생체 인증 지원 여부를 확인하지 못했습니다.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> authenticate({required String reason}) async {
    try {
      final authenticated = await _dataSource.authenticate(reason: reason);

      return Right(authenticated);
    } on LocalAuthException catch (e) {
      // 사용자 취소·시스템 취소·시간 초과는 잠금을 유지
      if (e.code == LocalAuthExceptionCode.userCanceled ||
          e.code == LocalAuthExceptionCode.systemCanceled ||
          e.code == LocalAuthExceptionCode.timeout) {
        return const Right(false);
      }

      return Left(_mapException(e));
    } catch (_) {
      return const Left(
        AppLockFailure(
          code: AppLockFailureCode.unknown,
          message: '생체 인증 중 오류가 발생했습니다.',
        ),
      );
    }
  }

  @override
  Future<void> stopAuthentication() {
    return _dataSource.stopAuthentication();
  }

  // 플러그인 오류를 앱에서 사용하는 오류로 변환
  AppLockFailure _mapException(LocalAuthException exception) {
    final (code, message) = switch (exception.code) {
      LocalAuthExceptionCode.noBiometricHardware => (
        AppLockFailureCode.unsupported,
        '생체 인증을 지원하지 않는 기기입니다.',
      ),
      LocalAuthExceptionCode.noBiometricsEnrolled ||
      LocalAuthExceptionCode.noCredentialsSet => (
        AppLockFailureCode.notEnrolled,
        '기기 설정에서 잠금과 생체 정보를 등록해주세요.',
      ),
      LocalAuthExceptionCode.biometricHardwareTemporarilyUnavailable ||
      LocalAuthExceptionCode.uiUnavailable => (
        AppLockFailureCode.temporarilyUnavailable,
        '현재 생체 인증을 사용할 수 없습니다. 잠시 후 다시 시도해주세요.',
      ),
      LocalAuthExceptionCode.temporaryLockout => (
        AppLockFailureCode.temporaryLockout,
        '인증 시도가 일시적으로 제한되었습니다. 잠시 후 다시 시도해주세요.',
      ),
      LocalAuthExceptionCode.biometricLockout => (
        AppLockFailureCode.biometricLockout,
        '기기에서 생체 인증 잠금 상태를 해제한 뒤 다시 시도해주세요.',
      ),
      LocalAuthExceptionCode.authInProgress => (
        AppLockFailureCode.authenticationInProgress,
        '이미 인증이 진행 중입니다.',
      ),
      LocalAuthExceptionCode.userRequestedFallback => (
        AppLockFailureCode.fallbackRequested,
        '다른 인증 방법을 선택했습니다. 기존 로그인으로 진행해주세요.',
      ),
      _ => (AppLockFailureCode.unknown, '생체 인증 중 오류가 발생했습니다.'),
    };

    return AppLockFailure(code: code, message: message);
  }

  @override
  Future<Either<Failure, bool>> isEnabled(int userId) async {
    try {
      final enabled = await _settingsDataSource.isEnabled(userId);
      return Right(enabled);
    } catch (_) {
      // 읽기 실패를 '잠금 꺼짐'으로 처리하지 않음
      return const Left(
        AppLockFailure(
          code: AppLockFailureCode.unknown,
          message: '앱 잠금 설정을 불러오지 못했습니다.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> setEnabled({
    required int userId,
    required bool enabled,
  }) async {
    try {
      await _settingsDataSource.setEnabled(userId: userId, enabled: enabled);

      return const Right(unit);
    } catch (_) {
      return const Left(
        AppLockFailure(
          code: AppLockFailureCode.unknown,
          message: '앱 잠금 설정을 저장하지 못했습니다.',
        ),
      );
    }
  }
}
