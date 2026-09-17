import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/failures.dart';

part 'app_lock_state.freezed.dart';

@freezed
abstract class AppLockState with _$AppLockState {
  const factory AppLockState({
    // 현재 상태가 어느 계정의 것인지
    int? userId,

    // 저장된 설정을 아직 확인하지 않았으면 null
    bool? isEnabled,

    // 설정 조회가 끝나기 전에는 앱 내용을 보호
    @Default(true) bool isLocked,

    // 계정의 잠금 설정을 처음 읽는 중인지
    @Default(true) bool isInitializing,

    // 인증 요청 또는 인증 후 설정 저장이 진행 중인지
    @Default(false) bool isProcessing,

    // 화면에서 안내할 오류
    Failure? failure,
  }) = _AppLockState;
}
