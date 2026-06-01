import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/styles/app_colors.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/settings/data/constants/setting_constants.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';
import 'package:loop/src/features/settings/presentation/providers/setting_providers.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_login_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_profile_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_section_widget.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  bool _imageRefreshing = false;

  Future<void> _refreshUserImage() async {
    if (_imageRefreshing) return; // 무한 재시도 방지
    _imageRefreshing = true;
    await ref.read(loginProvider.notifier).restoreSession();
    _imageRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final user = loginState.maybeWhen(
      success: (user) => user,
      orElse: () => null,
    );
    final isLoggedIn = user != null;
    final sections = isLoggedIn
        ? SettingConstants.loggedInSections
        : SettingConstants.notLoggedInSections;

    Future<void> getProfileImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile == null) return;

      // 서버에 업로드할 request 생성
      final request = ProfileRequestModel(image: pickedFile.path);
      final result = await ref
          .read(settingRepositoryProvider)
          .updateProfile(request, user!);

      result.match(
        (failure) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('업로드 실패: ${failure.errorMessage}')),
        ),
        (updatedUser) {
          // 상태 갱신 로직 (예: Provider/Notifier에 반영)
          ref.read(loginProvider.notifier).updateUser(updatedUser);
        },
      );
    }

    return DefaultLayout(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.primaryGradient,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Profile or Login Card
                  isLoggedIn
                      ? SettingProfileCardWidget(
                          user: user,
                          onEditTap: getProfileImage,
                          onImageError: _refreshUserImage,
                        )
                      : SettingLoginCardWidget(
                          onLoginTap: () => context.push(AppRoute.login.path),
                        ),
                  const SizedBox(height: 24),
                  // Settings Sections
                  ...sections.map(
                    (section) => Column(
                      children: [
                        SettingSectionWidget(section: section),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  // Logout Button
                  if (isLoggedIn)
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await ref.read(loginProvider.notifier).logout();
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('로그아웃 되었습니다.')),
                            );
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: AppColors.surface,
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '로그아웃',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  // Version
                  Text(
                    SettingConstants.appVersion,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
