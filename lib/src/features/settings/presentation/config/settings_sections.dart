import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';

const _activity = SettingsSectionDefinition(SettingsSectionId.activity, [
  SettingsMenuId.comments,
  SettingsMenuId.chat,
  SettingsMenuId.attendance,
  SettingsMenuId.notifications,
  SettingsMenuId.blockedUsers,
]);
const _preferences = SettingsSectionDefinition(SettingsSectionId.preferences, [
  SettingsMenuId.notificationSettings,
  SettingsMenuId.theme,
  SettingsMenuId.language,
]);
const _support = SettingsSectionDefinition(SettingsSectionId.support, [
  SettingsMenuId.notice,
  SettingsMenuId.contact,
  SettingsMenuId.terms,
]);
const _admin = SettingsSectionDefinition(SettingsSectionId.admin, [
  SettingsMenuId.adminWebView,
  SettingsMenuId.serverStatus,
]);

// 노출 조건만 조합한다. 번역·API 호출·상태 저장은 하지 않는다.
List<SettingsSectionDefinition> buildSettingsSections({
  required bool isLoggedIn,
  required bool isAdmin,
}) => List.unmodifiable([
  if (isLoggedIn) _activity,
  SettingsSectionDefinition(
    SettingsSectionId.tools,
    List.unmodifiable([
      if (isLoggedIn) SettingsMenuId.ocr,
      // 기존 Bluetooth FAB는 비로그인 상태에서도 사용할 수 있었다.
      SettingsMenuId.bluetooth,
    ]),
  ),
  _preferences,
  _support,
  if (isLoggedIn && isAdmin) _admin,
]);
