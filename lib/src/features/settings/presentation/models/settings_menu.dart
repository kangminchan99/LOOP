import 'package:flutter/material.dart';
import 'package:loop/l10n/app_localizations.dart';

enum SettingsMenuId {
  comments,
  chat,
  attendance,
  notifications,
  blockedUsers,
  ocr,
  bluetooth,
  notificationSettings,
  theme,
  language,
  notice,
  contact,
  terms,
  adminWebView,
  serverStatus,
  couponEvents,
}

enum SettingsSectionId { activity, tools, preferences, support, admin }

class SettingsSectionDefinition {
  const SettingsSectionDefinition(this.id, this.items);
  final SettingsSectionId id;
  final List<SettingsMenuId> items;
}

extension SettingsSectionPresentation on SettingsSectionId {
  String label(AppLocalizations l10n) => switch (this) {
    SettingsSectionId.activity => l10n.settingsActivity,
    SettingsSectionId.tools => l10n.settingsTools,
    SettingsSectionId.preferences => l10n.settingsAppSettings,
    SettingsSectionId.support => l10n.settingsSupport,
    SettingsSectionId.admin => l10n.settingsAdmin,
  };
}

extension SettingsMenuPresentation on SettingsMenuId {
  // 미구현 메뉴는 이동하는 것처럼 보이지 않게 비활성화한다.
  bool get isImplemented => switch (this) {
    SettingsMenuId.blockedUsers ||
    SettingsMenuId.notificationSettings ||
    SettingsMenuId.notice ||
    SettingsMenuId.contact ||
    SettingsMenuId.terms => false,
    _ => true,
  };

  String label(AppLocalizations l10n) => switch (this) {
    SettingsMenuId.comments => l10n.settingsMyComments,
    SettingsMenuId.chat => l10n.settingsChat,
    SettingsMenuId.attendance => l10n.settingsAttendanceCheck,
    SettingsMenuId.notifications => l10n.settingsNotificationList,
    SettingsMenuId.blockedUsers => l10n.settingsBlockedUsers,
    SettingsMenuId.ocr => l10n.ocrTitle,
    SettingsMenuId.bluetooth => l10n.settingsBluetooth,
    SettingsMenuId.notificationSettings => l10n.settingsNotificationSettings,
    SettingsMenuId.theme => l10n.settingsDisplayMode,
    SettingsMenuId.language => l10n.settingsLanguage,
    SettingsMenuId.notice => l10n.settingsNotice,
    SettingsMenuId.contact => l10n.settingsContact,
    SettingsMenuId.terms => l10n.settingsTermsPrivacy,
    SettingsMenuId.adminWebView => l10n.settingsAdminWebView,
    SettingsMenuId.serverStatus => l10n.settingsServerStatus,
    SettingsMenuId.couponEvents => l10n.couponEventsTitle,
  };

  IconData get icon => switch (this) {
    SettingsMenuId.comments => Icons.comment_outlined,
    SettingsMenuId.chat => Icons.chat_bubble_outline,
    SettingsMenuId.attendance => Icons.event_available_outlined,
    SettingsMenuId.notifications => Icons.notifications_outlined,
    SettingsMenuId.blockedUsers => Icons.block_outlined,
    SettingsMenuId.ocr => Icons.document_scanner_outlined,
    SettingsMenuId.bluetooth => Icons.bluetooth,
    SettingsMenuId.notificationSettings => Icons.notifications_active_outlined,
    SettingsMenuId.theme => Icons.contrast,
    SettingsMenuId.language => Icons.language,
    SettingsMenuId.notice => Icons.campaign_outlined,
    SettingsMenuId.contact => Icons.help_outline,
    SettingsMenuId.terms => Icons.description_outlined,
    SettingsMenuId.adminWebView => Icons.admin_panel_settings_outlined,
    SettingsMenuId.serverStatus => Icons.monitor_heart_outlined,
    SettingsMenuId.couponEvents => Icons.local_offer_outlined,
  };
}
