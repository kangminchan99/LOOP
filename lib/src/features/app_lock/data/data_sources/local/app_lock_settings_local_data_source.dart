import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockSettingsLocalDataSource {
  final FlutterSecureStorage _storage;

  AppLockSettingsLocalDataSource(this._storage);

  // 계정마다 잠금 설정을 분리
  String _key(int userId) => 'app_lock_enabled_v1_$userId';

  Future<bool> isEnabled(int userId) async {
    final value = await _storage.read(key: _key(userId));

    // 저장한 설정이 없으면 기본값은 꺼짐
    if (value == null) return false;

    if (value == 'true') return true;
    if (value == 'false') return false;

    // 잘못된 값을 잠금 해제로 처리하지 않음
    throw const FormatException('잠금 설정 값이 올바르지 않습니다.');
  }

  Future<void> setEnabled({required int userId, required bool enabled}) async {
    await _storage.write(key: _key(userId), value: enabled.toString());
  }
}
