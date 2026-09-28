import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

enum SettingsOperation { idle, profile, logout }

enum SettingsActionResult {
  success,
  cancelled,
  ignored,
  failed,
  logoutWithWarning,
}

// 플러그인/인증은 주입하고 진행 상태와 세션 유효성만 관리한다.
class SettingsActionsNotifier extends StateNotifier<SettingsOperation> {
  SettingsActionsNotifier({
    required Future<String?> Function() pickImage,
    required AbstractSettingRepository repository,
    required UserModel? Function() currentUser,
    required int Function() sessionRevision,
    required Future<void> Function(UserModel) applyUser,
    required Future<bool> Function() unregisterDevice,
    required Future<void> Function() logout,
  }) : _pickImage = pickImage,
       _repository = repository,
       _currentUser = currentUser,
       _sessionRevision = sessionRevision,
       _applyUser = applyUser,
       _unregisterDevice = unregisterDevice,
       _logout = logout,
       super(SettingsOperation.idle);

  final Future<String?> Function() _pickImage;
  final AbstractSettingRepository _repository;
  final UserModel? Function() _currentUser;
  final int Function() _sessionRevision;
  final Future<void> Function(UserModel) _applyUser;
  final Future<bool> Function() _unregisterDevice;
  final Future<void> Function() _logout;

  bool _isCurrent(int userId, int revision) =>
      mounted && _sessionRevision() == revision && _currentUser()?.id == userId;

  Future<SettingsActionResult> updateProfile() async {
    if (!mounted || state != SettingsOperation.idle) {
      return SettingsActionResult.ignored;
    }
    final user = _currentUser();
    if (user == null) return SettingsActionResult.ignored;
    final revision = _sessionRevision();
    state = SettingsOperation.profile;
    try {
      final path = await _pickImage();
      if (!_isCurrent(user.id, revision)) return SettingsActionResult.ignored;
      if (path == null) return SettingsActionResult.cancelled;
      final result = await _repository.updateProfile(
        ProfileRequestModel(image: path),
        user,
      );
      if (!_isCurrent(user.id, revision)) return SettingsActionResult.ignored;
      return await result.fold<Future<SettingsActionResult>>(
        (_) async => SettingsActionResult.failed,
        (updated) async {
          // 요청 중 바뀐 포인트/닉네임을 오래된 스냅샷으로 덮지 않는다.
          final latest = _currentUser()!;
          await _applyUser(
            latest.copyWith(profileImageUrl: updated.profileImageUrl),
          );
          return _isCurrent(user.id, revision)
              ? SettingsActionResult.success
              : SettingsActionResult.ignored;
        },
      );
    } catch (_) {
      return _isCurrent(user.id, revision)
          ? SettingsActionResult.failed
          : SettingsActionResult.ignored;
    } finally {
      if (mounted) state = SettingsOperation.idle;
    }
  }

  Future<SettingsActionResult> logout() async {
    if (!mounted || state != SettingsOperation.idle) {
      return SettingsActionResult.ignored;
    }
    final user = _currentUser();
    if (user == null) return SettingsActionResult.ignored;
    final revision = _sessionRevision();
    state = SettingsOperation.logout;
    try {
      var detached = false;
      try {
        detached = await _unregisterDevice();
      } catch (_) {
        // FCM 연결 해제 실패가 사용자 로그아웃을 막지 않는다.
      }
      if (!_isCurrent(user.id, revision)) return SettingsActionResult.ignored;
      await _logout();
      if (!mounted) return SettingsActionResult.ignored;
      return detached
          ? SettingsActionResult.success
          : SettingsActionResult.logoutWithWarning;
    } catch (_) {
      return mounted
          ? SettingsActionResult.failed
          : SettingsActionResult.ignored;
    } finally {
      if (mounted) state = SettingsOperation.idle;
    }
  }
}
