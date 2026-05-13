import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/auth/domain/models/sign_up_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/presentation/providers/sign_up/sign_up_state.dart';

class SignUpStateNotifier extends StateNotifier<SignUpState> {
  final AbstractAuthRepository _authRepository;

  SignUpStateNotifier(this._authRepository)
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

    state = result.match(
      (failure) => SignUpState.error(failure.errorMessage),
      (user) => SignUpState.success(user),
    );
  }

  // 에러 메시지 닫기/재시도 전에 상태 초기화할 때 사용
  void reset() {
    state = const SignUpState.initial();
  }
}
