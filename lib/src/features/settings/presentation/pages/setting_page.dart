import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/layout/max_width_container.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/features/app_lock/presentation/widgets/app_lock_setting_tile.dart';
import 'package:loop/src/features/attendance/presentation/widgets/attendance_dialog_widget.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/settings/presentation/config/settings_sections.dart';
import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';
import 'package:loop/src/features/settings/presentation/providers/settings_actions_notifier.dart';
import 'package:loop/src/features/settings/presentation/providers/settings_actions_provider.dart';
import 'package:loop/src/features/settings/presentation/widgets/language_dialog_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_login_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_profile_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_section_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/settings_menu_tile.dart';
import 'package:loop/src/features/settings/presentation/widgets/theme_mode_dialog_widget.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});
  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _opening = false;

  // 이동과 다이얼로그는 Presentation에서만 처리한다.
  Future<void> _openMenu(SettingsMenuId id) async {
    if (_opening || !id.isImplemented) return;
    _opening = true;
    try {
      switch (id) {
        case SettingsMenuId.attendance:
          await showDialog<void>(
            context: context,
            builder: (_) => const AttendanceDialog(),
          );
        case SettingsMenuId.language:
          await showDialog<void>(
            context: context,
            builder: (_) => const LanguageDialogWidget(),
          );
        case SettingsMenuId.theme:
          await showDialog<void>(
            context: context,
            builder: (_) => const ThemeModeDialogWidget(),
          );
        case SettingsMenuId.comments:
          await context.pushNamed<void>(AppRoute.commentList.name);
        case SettingsMenuId.chat:
          await context.pushNamed<void>(AppRoute.chatRooms.name);
        case SettingsMenuId.notifications:
          await context.pushNamed<void>(AppRoute.notifications.name);
        case SettingsMenuId.ocr:
          await context.pushNamed<void>(AppRoute.ocr.name);
        case SettingsMenuId.bluetooth:
          await context.pushNamed<void>(AppRoute.bluetooth.name);
        case SettingsMenuId.adminWebView:
          await context.pushNamed<void>(AppRoute.adminWebView.name);
        case SettingsMenuId.serverStatus:
          await context.pushNamed<void>(AppRoute.adminServerStatus.name);
        case SettingsMenuId.blockedUsers:
        case SettingsMenuId.notificationSettings:
        case SettingsMenuId.notice:
        case SettingsMenuId.contact:
        case SettingsMenuId.terms:
          return;
      }
    } finally {
      _opening = false;
    }
  }

  Future<void> _updateProfile() async {
    final result =
        await ref.read(settingsActionsProvider.notifier).updateProfile();
    if (!mounted || result != SettingsActionResult.failed) return;
    _message(AppLocalizations.of(context).settingsProfileUpdateFailed);
  }

  Future<void> _logout() async {
    final result = await ref.read(settingsActionsProvider.notifier).logout();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    switch (result) {
      case SettingsActionResult.success:
        _message(l10n.settingsLogoutComplete);
      case SettingsActionResult.logoutWithWarning:
        _message(l10n.settingsLogoutDeviceWarning);
      case SettingsActionResult.failed:
        _message(l10n.settingsLogoutFailed);
      case SettingsActionResult.cancelled:
      case SettingsActionResult.ignored:
        return;
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(
      loginProvider.select(
        (state) => state is LoginSuccess ? state.user : null,
      ),
    );
    final operation = ref.watch(settingsActionsProvider);
    final busy = operation != SettingsOperation.idle;
    final sections = buildSettingsSections(
      isLoggedIn: user != null,
      isAdmin: user?.role == 'ADMIN',
    );

    return DefaultLayout(
      child: SafeArea(
        child: MaxWidthContainer(
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            children: [
              if (user != null)
                SettingProfileCardWidget(
                  user: user,
                  isUpdating: operation == SettingsOperation.profile,
                  onEditTap: busy ? null : _updateProfile,
                )
              else
                SettingLoginCardWidget(
                  onLoginTap: () => context.push(AppRoute.login.path),
                ),
              const SizedBox(height: 24),
              for (final section in sections) ...[
                SettingSectionWidget(
                  title: section.id.label(l10n),
                  children: [
                    for (var index = 0; index < section.items.length; index++)
                      SettingsMenuTile(
                        key: ValueKey(section.items[index]),
                        id: section.items[index],
                        showDivider: index < section.items.length - 1,
                        onTap: () => _openMenu(section.items[index]),
                      ),
                  ],
                ),
                if (section.id == SettingsSectionId.preferences &&
                    user != null) ...[
                  const SizedBox(height: 12),
                  AppLockSettingTile(userId: user.id),
                ],
                const SizedBox(height: 24),
              ],
              if (user != null) ...[
                OutlinedButton.icon(
                  onPressed: busy ? null : _logout,
                  icon:
                      operation == SettingsOperation.logout
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.logout),
                  label: Text(
                    operation == SettingsOperation.logout
                        ? l10n.settingsProcessing
                        : l10n.settingsLogout,
                  ),
                ),
                const SizedBox(height: 24),
              ],
              // 빌드와 불일치하는 고정 버전은 표시하지 않는다.
              Text(
                l10n.appTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
