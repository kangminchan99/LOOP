import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';

class LoginStateNotifier extends StateNotifier<LoginState>{
  final AbstractAuthRepository _authRepository;

  LoginStateNotifier(this._authRepository) : super(const LoginState.initial());

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const LoginState.loading();

    final result = await _authRepository.login(
      LoginRequestModel(email: email, password: password),
    );

    state = result.match(
      (failure) => LoginState.error(failure.errorMessage),
      (user) => LoginState.success(user),
    );
  }

    void reset() {
    state = const LoginState.initial();
  }
}