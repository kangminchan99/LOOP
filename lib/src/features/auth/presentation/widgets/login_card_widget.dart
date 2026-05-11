import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/router/router_path.dart';
import 'package:loop/src/core/styles/app_colors.dart';

class LoginCardWidget extends StatefulWidget {
  const LoginCardWidget({super.key});

  @override
  State<LoginCardWidget> createState() => _LoginCardWidgetState();
}

class _LoginCardWidgetState extends State<LoginCardWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 32,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Title
          Text(
            '시작하기',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Text(
            '나와 비슷한 생각을 가진 사람들과 가볍게 연결돼요.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 28),

          /// ID
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: '아이디 또는 이메일',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Password
          SizedBox(
            width: double.infinity,
            height: 56,
            child: TextFormField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: '비밀번호',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          /// Sign Up
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '아직 계정이 없나요?',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => context.push(AppRoute.signUp.path),
                child: const Text(
                  '회원가입',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
