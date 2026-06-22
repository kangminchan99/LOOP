import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/attendance/domain/repositories/abstract_attendance_repository.dart';
import 'package:loop/src/features/attendance/domain/usecases/check_in_attendance_result.dart';
import 'package:loop/src/features/auth/domain/repositories/abstract_auth_repository.dart';

class CheckInAttendanceUseCase {
  const CheckInAttendanceUseCase({
    required this.attendanceRepository,
    required this.authRepository,
  });

  final AbstractAttendanceRepository attendanceRepository;
  final AbstractAuthRepository authRepository;

  Future<Either<Failure, CheckInAttendanceResult>> call() async {
    final attendanceResult = await attendanceRepository.checkIn();

    return attendanceResult.fold((failure) => Left(failure), (
      attendance,
    ) async {
      final userResult = await authRepository.getMe();

      return userResult.fold(
        (failure) => Left(failure),
        (user) =>
            Right(CheckInAttendanceResult(attendance: attendance, user: user)),
      );
    });
  }
}
