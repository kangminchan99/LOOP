import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/notifications/presentation/providers/notification_providers.dart';
import 'settings_actions_notifier.dart';
import 'setting_providers.dart';

final settingsActionsProvider = StateNotifierProvider.autoDispose<
  SettingsActionsNotifier,
  SettingsOperation
>((ref) {
  var revision = 0;
  // 같은 ID로 재로그인해도 중간 세션 종료가 있으면 이전 작업을 무효화한다.
  ref.listen<int?>(
    loginProvider.select(
      (state) => state is LoginSuccess ? state.user.id : null,
    ),
    (previous, next) {
      if (previous != next) revision++;
    },
  );
  return SettingsActionsNotifier(
    pickImage:
        () async =>
            (await ImagePicker().pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            ))?.path,
    repository: ref.watch(settingRepositoryProvider),
    currentUser: () {
      final login = ref.read(loginProvider);
      return login is LoginSuccess ? login.user : null;
    },
    sessionRevision: () => revision,
    applyUser: (user) => ref.read(loginProvider.notifier).updateUser(user),
    unregisterDevice:
        () async => (await ref.read(deleteFcmTokenUseCaseProvider)()).fold(
          (_) => false,
          (_) => true,
        ),
    logout: () => ref.read(loginProvider.notifier).logout(),
  );
});
