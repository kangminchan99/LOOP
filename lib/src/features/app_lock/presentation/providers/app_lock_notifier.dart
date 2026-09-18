import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/network/error/app_lock_failure.dart';
import 'package:loop/src/features/app_lock/domain/usecases/authenticate_app_lock_usecase.dart';
import 'package:loop/src/features/app_lock/domain/usecases/change_app_lock_setting_usecase.dart';

import '../../domain/repositories/abstract_app_lock_repository.dart';
import 'app_lock_state.dart';

class AppLockNotifier extends StateNotifier<AppLockState> {
  final AbstractAppLockRepository _repository;
  final AuthenticateAppLockUseCase _authenticate;
  final ChangeAppLockSettingUseCase _changeSetting;

  // 이전 요청의 결과가 최신 상태를 덮어쓰지 않도록 구분
  int _requestId = 0;

  // 인증·설정 변경 중 앱을 나갔는지 기억한다.
  bool _lockRequested = false;

  AppLockNotifier(this._repository, this._authenticate, this._changeSetting)
    : super(const AppLockState());

  Future<void> initialize(int userId) async {
    if (!mounted) return;

    _lockRequested = false;

    final requestId = ++_requestId;

    // 설정을 읽기 전에는 잠금 상태로 시작
    state = AppLockState(userId: userId);

    final result = await _repository.isEnabled(userId);

    // 폐기된 Notifier나 이전 요청의 결과는 무시
    if (!mounted || requestId != _requestId) return;

    result.fold(
      (failure) {
        // 조회 실패 시 잠금을 풀지 않음
        state = state.copyWith(
          isInitializing: false,
          isLocked: true,
          failure: failure,
        );
      },
      (enabled) {
        state = state.copyWith(
          isInitializing: false,
          isEnabled: enabled,
          isLocked: enabled,
          failure: null,
        );
      },
    );
  }

  Future<void> unlock({required String reason}) async {
    if (!mounted) return;

    // 초기화 중이거나 이미 처리 중이면 실행하지 않음
    if (state.isInitializing || state.isProcessing) return;

    // 정상적으로 설정을 읽은 잠금 계정만 인증
    if (state.userId == null || state.isEnabled != true || !state.isLocked) {
      return;
    }

    final userId = state.userId;
    final requestId = ++_requestId;

    state = state.copyWith(isProcessing: true, failure: null);

    // 실제 생체 인증
    final result = await _authenticate(reason: reason);

    // 인증 도중 초기화·계정 변경이 일어났다면 결과 무시
    if (!mounted || requestId != _requestId || state.userId != userId) {
      return;
    }

    result.fold(
      (failure) {
        state = state.copyWith(
          isProcessing: false,
          isLocked: true,
          failure: failure,
        );
      },
      (authenticated) {
        state = state.copyWith(
          isProcessing: false,
          // 인증에 성공해도 도중에 앱을 나갔다면 잠금을 유지한다.
          isLocked: !authenticated || _lockRequested,
          failure: null,
        );
      },
    );

    _lockRequested = false;
  }

  Future<void> changeEnabled({
    required bool enabled,
    required String reason,
  }) async {
    if (!mounted) return;

    final userId = state.userId;

    // 설정을 정상 조회한 상태에서만 변경 가능
    if (userId == null ||
        state.isInitializing ||
        state.isProcessing ||
        state.isEnabled == null ||
        state.isLocked) {
      return;
    }

    // 이미 같은 설정이면 인증하지 않음
    if (state.isEnabled == enabled) return;

    final requestId = ++_requestId;

    bool isCurrent() =>
        mounted && requestId == _requestId && state.userId == userId;

    state = state.copyWith(isProcessing: true, failure: null);

    final result = await _changeSetting(
      userId: userId,
      enabled: enabled,
      reason: reason,
      isCurrent: isCurrent,
    );

    if (!isCurrent()) return;

    result.fold(
      (failure) {
        // 저장 결과까지 확신할 수 없으므로 설정을 다시 확인하도록 보호
        state = state.copyWith(
          isProcessing: false,
          isEnabled: null,
          isLocked: true,
          failure: failure,
        );
      },
      (changed) {
        if (!changed) {
          // 취소하면 기존 설정을 유지하되, 필요한 재잠금은 반영한다.
          state = state.copyWith(
            isProcessing: false,
            isLocked:
                state.isLocked || (_lockRequested && state.isEnabled == true),
          );
          return;
        }

        state = state.copyWith(
          isProcessing: false,
          isEnabled: enabled,
          // OFF 변경이 성공했다면 재잠금하지 않는다.
          isLocked: enabled && _lockRequested,
          failure: null,
        );
      },
    );
    _lockRequested = false;
  }

  void lock() {
    if (!mounted || state.userId == null || state.isInitializing) {
      return;
    }

    // 처리 중이면 결과가 돌아왔을 때 재잠금을 반영한다.
    if (state.isProcessing) {
      _lockRequested = true;
      return;
    }

    if (state.isEnabled != true || state.isLocked) return;

    state = state.copyWith(isLocked: true, failure: null);
  }

  Future<bool> reset() async {
    if (!mounted) return false;

    _lockRequested = false;

    // 진행 중인 이전 요청의 결과를 무효화
    final requestId = ++_requestId;

    // 계정 정보와 잠금 해제 상태를 즉시 제거
    state = const AppLockState();

    try {
      // OS에서 진행 중인 인증도 취소 요청
      await _repository.stopAuthentication();

      return mounted && requestId == _requestId;
    } catch (_) {
      if (!mounted || requestId != _requestId) return false;

      // 취소 요청 처리에 오류가 나면 보호 상태 유지
      state = state.copyWith(
        isInitializing: false,
        isLocked: true,
        failure: const AppLockFailure(
          code: AppLockFailureCode.unknown,
          message: '인증 상태를 초기화하지 못했습니다. 다시 시도해주세요.',
        ),
      );

      return false;
    }
  }
}
