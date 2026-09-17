import 'package:local_auth/local_auth.dart';
import 'package:loop/src/features/app_lock/domain/models/biometric_capability_model.dart';

class BiometricLocalDataSource {
  final LocalAuthentication _auth;

  BiometricLocalDataSource(this._auth);

  // 기기의 생체 인증 지원 등록 여부 확인
  Future<BiometricCapabilityModel> getBiometricCapability() async {
    final isSupported = await _auth.canCheckBiometrics;

    if (!isSupported) {
      return const BiometricCapabilityModel(
        isSupported: false,
        isEnrolled: false,
      );
    }

    final biometrics = await _auth.getAvailableBiometrics();

    return BiometricCapabilityModel(
      isSupported: true,
      isEnrolled: biometrics.isNotEmpty,
    );
  }

  // os의 생체 인증창 표시
  Future<bool> authenticate({required String reason}) {
    return _auth.authenticate(
      localizedReason: reason,
      biometricOnly: true,
      persistAcrossBackgrounding: false,
    );
  }

  // 진챙 중인 인증 취소
  Future<void> stopAuthentication() async {
    await _auth.stopAuthentication();
  }
}
