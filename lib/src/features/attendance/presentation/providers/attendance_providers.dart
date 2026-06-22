import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/attendance/data/data_sources/remote/attendance_api.dart';
import 'package:loop/src/features/attendance/data/repositories/attendance_repository_impl.dart';
import 'package:loop/src/features/attendance/domain/repositories/abstract_attendance_repository.dart';
import 'package:loop/src/features/attendance/domain/usecases/check_in_attendance_usecase.dart';
import 'package:loop/src/features/attendance/presentation/providers/attendance_notifier.dart';
import 'package:loop/src/features/attendance/presentation/providers/attendance_state.dart';
import 'package:loop/src/features/auth/presentation/providers/auth_providers.dart';

final attendanceApiProvider = Provider<AttendanceApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AttendanceApi(dio);
});

final attendanceRepositoryProvider = Provider<AbstractAttendanceRepository>((
  ref,
) {
  return AttendanceRepositoryImpl(ref.watch(attendanceApiProvider));
});

final checkInAttendanceUseCaseProvider = Provider<CheckInAttendanceUseCase>((
  ref,
) {
  return CheckInAttendanceUseCase(
    attendanceRepository: ref.watch(attendanceRepositoryProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
      return AttendanceNotifier(
        ref.watch(attendanceRepositoryProvider),
        ref.watch(checkInAttendanceUseCaseProvider),
        ref.read(loginProvider.notifier),
      );
    });
