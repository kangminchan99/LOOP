import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/features/attendance/domain/models/attendance_model.dart';

part 'attendance_state.freezed.dart';

@freezed
sealed class AttendanceState with _$AttendanceState {
  const factory AttendanceState.initial() = AttendanceInitial;

  const factory AttendanceState.loading() = AttendanceLoading;

  const factory AttendanceState.success(AttendanceModel attendance) =
      AttendanceSuccess;

  const factory AttendanceState.checkingIn(AttendanceModel? attendance) =
      AttendanceCheckingIn;

  const factory AttendanceState.error(String message) = AttendanceError;
}
