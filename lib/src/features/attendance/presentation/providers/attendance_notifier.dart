import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/attendance/domain/repositories/abstract_attendance_repository.dart';
import 'package:loop/src/features/attendance/domain/usecases/check_in_attendance_usecase.dart';
import 'package:loop/src/features/attendance/presentation/providers/attendance_state.dart';
import 'package:loop/src/features/auth/presentation/providers/login/login_state_notifier.dart';

class AttendanceNotifier extends StateNotifier<AttendanceState> {
  AttendanceNotifier(
    this._repository,
    this._checkInAttendanceUseCase,
    this._loginNotifier,
  ) : super(const AttendanceState.initial()) {
    load();
  }

  final AbstractAttendanceRepository _repository;
  final CheckInAttendanceUseCase _checkInAttendanceUseCase;
  final LoginStateNotifier _loginNotifier;

  Future<void> load() async {
    state = const AttendanceState.loading();

    final result = await _repository.getMyAttendance();

    state = result.fold(
      (failure) => AttendanceState.error(failure.errorMessage),
      (attendance) => AttendanceState.success(attendance),
    );
  }

  Future<void> checkIn() async {
    final current = state;

    state = AttendanceState.checkingIn(
      current is AttendanceSuccess ? current.attendance : null,
    );

    final result = await _checkInAttendanceUseCase();

    state = result.fold(
      (failure) => AttendanceState.error(failure.errorMessage),
      (data) {
        _loginNotifier.updateUser(data.user);
        return AttendanceState.success(data.attendance);
      },
    );
  }
}
