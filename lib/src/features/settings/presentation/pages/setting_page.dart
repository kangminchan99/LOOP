import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/layout/default_layout.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/styles/app_colors.dart';
import 'package:loop/src/features/settings/data/constants/setting_constants.dart';
import 'package:loop/src/features/settings/data/models/setting_model.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_login_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_profile_card_widget.dart';
import 'package:loop/src/features/settings/presentation/widgets/setting_section_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isLoggedIn = false;

  List<SettingSection> get sections => isLoggedIn
      ? SettingConstants.loggedInSections
      : SettingConstants.notLoggedInSections;

  @override
  Widget build(BuildContext context) {
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
                          onEditTap: () {
                            // Edit profile action
                          },
                        )
                      : SettingLoginCardWidget(
                          onLoginTap: () {
                            setState(() {
                              isLoggedIn = true;
                            });
                            context.push(AppRoute.login.path);
                          },
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
                          onTap: () {
                            setState(() {
                              isLoggedIn = false;
                            });
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
