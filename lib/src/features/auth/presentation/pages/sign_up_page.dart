import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/styles/app_colors.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';
import 'package:loop/src/features/auth/presentation/providers/sign_up/sign_up_state.dart';
import 'package:loop/src/features/auth/presentation/widgets/signup_agreement_widget.dart';
import 'package:loop/src/features/auth/presentation/widgets/signup_input_field_widget.dart';

class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _nicknameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  bool _isAgreed = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (_nicknameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('모든 필드를 입력해주세요')));
      return;
    }

    if (_passwordController.text != _passwordConfirmController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('비밀번호가 일치하지 않습니다')));
      return;
    }

    if (!_isAgreed) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('약관에 동의해주세요')));
      return;
    }

    await ref
        .read(signUpProvider.notifier)
        .signUp(
          nickname: _nicknameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SignUpState>(signUpProvider, (previous, next) {
      next.whenOrNull(
        success: (user) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('회원가입이 완료되었습니다')));
          // context.go(AppRoute.login.path);
        },
        error: (message) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
      );
    });

    final signUpState = ref.watch(signUpProvider);
    final isLoading = signUpState is SignUpLoading;
    return Scaffold(
      body: Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, size: 30),
                          onPressed: () {
                            context.pop();
                          },
                        ),
                      ),
                      Text(
                        'welcome to loop',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '나만의 루프를\n시작해볼까요?',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '관심사와 생각을 공유하고,\n비슷한 사람들과 자연스럽게 연결돼요.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Form Card
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      color: AppColors.surface,
                      border: Border.all(color: Colors.white70, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Input Fields
                        Column(
                          children: [
                            SignupInputFieldWidget(
                              label: '닉네임',
                              placeholder: 'loop에서 사용할 이름',
                              controller: _nicknameController,
                            ),
                            const SizedBox(height: 16),
                            SignupInputFieldWidget(
                              label: '이메일',
                              placeholder: 'example@email.com',
                              controller: _emailController,
                            ),
                            const SizedBox(height: 16),
                            SignupInputFieldWidget(
                              label: '비밀번호',
                              placeholder: '8자 이상 입력',
                              isPasswordField: true,
                              controller: _passwordController,
                            ),
                            const SizedBox(height: 16),
                            SignupInputFieldWidget(
                              label: '비밀번호 확인',
                              placeholder: '비밀번호 재입력',
                              isPasswordField: true,
                              controller: _passwordConfirmController,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Agreement
                        SignupAgreementWidget(
                          initialValue: _isAgreed,
                          onChanged: (value) {
                            setState(() {
                              _isAgreed = value;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        // Sign Up Button
                        GestureDetector(
                          onTap: isLoading ? null : _handleSignUp,

                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: isLoading
                                  ? AppColors.textPrimary.withValues(alpha: 0.6)
                                  : AppColors.textPrimary,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      '가입하고 시작하기',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Login Link
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '이미 계정이 있나요?',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Warning Text
                  Text(
                    '안전한 커뮤니티를 위해 가입 후 일부 기능은 인증이 필요할 수 있어요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.6),
                      height: 1.4,
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
