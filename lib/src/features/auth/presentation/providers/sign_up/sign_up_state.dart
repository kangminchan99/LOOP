import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

part 'sign_up_state.freezed.dart';

@freezed
class SignUpState with _$SignUpState {
  const factory SignUpState.initial() = SignUpInitial;

  // API 요청 진행 중: 버튼 비활성/로딩 표시 기준으로 사용
  const factory SignUpState.loading() = SignUpLoading;

  // 가입 완료 후 화면 이동 기준으로 사용
  const factory SignUpState.success(UserModel user) = SignUpSuccess;

  // 사용자에게 보여줄 메시지 전달
  const factory SignUpState.error(String message) = SignUpError;
}
