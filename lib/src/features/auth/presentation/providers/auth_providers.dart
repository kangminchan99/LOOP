import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/auth/data/data_sources/remote/auth_api.dart';
import 'package:loop/src/features/auth/data/data_sources/remote/kakao_auth_data_source.dart';
import 'package:loop/src/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';
import 'package:loop/src/features/auth/domain/usecases/login_with_kakao_usecase.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';
import 'package:loop/src/features/auth/presentation/providers/sign_up/sign_up_state.dart';
import 'package:loop/src/features/auth/presentation/providers/sign_up/sign_up_state_notifier.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  // 공용 Dio 설정(인터셉터/타임아웃/로거)을 재사용
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

final kakaoAuthDataSourceProvider = Provider<KakaoAuthDataSource>((ref) {
  return KakaoAuthDataSource();
});

// 인터페이스 -> 구현체 주입
final authRepositoryProvider = Provider<AbstractAuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final kakaoAuthDataSourece = ref.watch(kakaoAuthDataSourceProvider);
  return AuthRepositoryImpl(api, secureStorage, kakaoAuthDataSourece);
});

final loginWithKakaoUseCaseProvider = Provider<LoginWithKakaoUsecase>((ref) {
  final repository = ref.watch(authRepositoryProvider);

  return LoginWithKakaoUsecase(authRepository: repository);
});

final signUpProvider = StateNotifierProvider<SignUpStateNotifier, SignUpState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpStateNotifier(repository);
});

final loginProvider = StateNotifierProvider<LoginStateNotifier, LoginState>((
  ref,
) {
  final repository = ref.watch(authRepositoryProvider);
  final secureStorage = ref.watch(secureStorageProvider);
  final loginWithKakaoUsecase = ref.watch(loginWithKakaoUseCaseProvider);
  return LoginStateNotifier(repository, secureStorage, loginWithKakaoUsecase);
});
