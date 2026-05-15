import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

part 'login_state.freezed.dart';

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState.initial() = LoginInitial;

  // 로그인 요청 중: 버튼 비활성/로딩 UI 표시
  const factory LoginState.loading() = LoginLoading;

  // 로그인 성공: 라우팅 트리거로 사용
  const factory LoginState.success(UserModel user) = LoginSuccess;

  // 로그인 실패: 스낵바 메시지로 사용
  const factory LoginState.error(String message) = LoginError;
}
