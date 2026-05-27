import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState.initial() = ProfileInitial;

  // 프로필 업데이트 요청 중: 버튼 비활성/로딩 UI 표시
  const factory ProfileState.loading() = ProfileLoading;

  // 프로필 업데이트 성공: 상태 갱신 등
  const factory ProfileState.success() = ProfileSuccess;

  // 프로필 업데이트 실패: 스낵바 메시지로 사용
  const factory ProfileState.error(String message) = ProfileError;
}
