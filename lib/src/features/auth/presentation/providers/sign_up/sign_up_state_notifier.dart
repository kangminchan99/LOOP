import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/analytics/analytics_service.dart';
import 'package:loop/src/features/auth/domain/models/sign_up_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/presentation/providers/sign_up/sign_up_state.dart';

class SignUpStateNotifier extends StateNotifier<SignUpState> {
  final AbstractAuthRepository _authRepository;
  final AnalyticsService _analyticsService;

  SignUpStateNotifier(this._authRepository, this._analyticsService)
    : super(const SignUpState.initial());

  Future<void> signUp({
    required String nickname,
    required String email,
    required String password,
  }) async {
    state = const SignUpState.loading();

    final result = await _authRepository.signUp(
      SignUpRequestModel(email: email, password: password, nickname: nickname),
    );

    await result.match(
      (failure) async {
        state = SignUpState.error(failure.errorMessage);
      },
      (user) async {
        state = SignUpState.success(user);
        await _analyticsService.logSignUp(method: 'email');
      },
    );
  }

  // 에러 메시지 닫기/재시도 전에 상태 초기화할 때 사용
  void reset() {
    state = const SignUpState.initial();
  }
}
