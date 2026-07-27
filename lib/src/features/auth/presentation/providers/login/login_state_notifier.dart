import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:loop/src/core/analytics/analytics_service.dart';
import 'package:loop/src/core/utils/constant/network_constant.dart';
import 'package:loop/src/features/auth/domain/models/login_request_model.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/domain/usecases/login_with_google_usecase.dart';
import 'package:loop/src/features/auth/domain/usecases/login_with_kakao_usecase.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class LoginStateNotifier extends StateNotifier<LoginState> {
  final AbstractAuthRepository _authRepository;
  final FlutterSecureStorage _secureStorage;
  final LoginWithKakaoUsecase _loginWithKakaoUsecase;
  final LoginWithGoogleUsecase _loginWithGoogleUsecase;
  final AnalyticsService _analyticsService;

  LoginStateNotifier(
    this._authRepository,
    this._secureStorage,
    this._loginWithKakaoUsecase,
    this._loginWithGoogleUsecase,
    this._analyticsService,
  ) : super(const LoginState.initial());

  Future<void> login({required String email, required String password}) async {
    state = const LoginState.loading();

    final result = await _authRepository.login(
      LoginRequestModel(email: email, password: password),
    );

    await result.match(
      (failure) async {
        state = LoginState.error(failure.errorMessage);
      },
      (user) async {
        state = LoginState.success(user);
        await _analyticsService.logLogin(method: 'email');
        await _analyticsService.setUserId(user.id);
      },
    );
  }

  Future<void> kakaoLogin() async {
    state = const LoginState.loading();

    final result = await _loginWithKakaoUsecase();

    await result.match(
      (failure) async {
        state = LoginState.error(failure.errorMessage);
      },
      (user) async {
        state = LoginState.success(user);
        await _analyticsService.logLogin(method: 'kakao');
        await _analyticsService.setUserId(user.id);
      },
    );
  }

  Future<void> googleLogin() async {
    state = const LoginState.loading();

    final result = await _loginWithGoogleUsecase();

    await result.match(
      (failure) async {
        state = LoginState.error(failure.errorMessage);
      },
      (user) async {
        state = LoginState.success(user);
        await _analyticsService.logLogin(method: 'google');
        await _analyticsService.setUserId(user.id);
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await _analyticsService.setUserId(null);
    state = const LoginState.initial();
  }

  Future<void> updateUser(UserModel user) async {
    state = LoginState.success(user);
  }

  // 앱 시작 시 토큰이 유효한지 확인하여 자동 로그인 처리
  Future<void> restoreSession() async {
    final token = await _secureStorage.read(key: kAccessTokenKey);
    if (token == null || token.isEmpty) {
      state = const LoginState.initial();
      return;
    }

    state = const LoginState.loading();
    final result = await _authRepository.getMe();

    await result.match(
      (failure) async {
        state = const LoginState.initial();
      },
      (user) async {
        state = LoginState.success(user);
        await _analyticsService.setUserId(user.id);
      },
    );
  }

  // 출석 체크 후 포인트 업데이트
  void updatePoint(int point) {
    final current = state;

    if (current is! LoginSuccess) return;

    state = LoginState.success(current.user.copyWith(point: point));
  }

  void reset() {
    state = const LoginState.initial();
  }
}
