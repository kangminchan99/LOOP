import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart' show Failure;
import 'package:loop/src/features/attendance/domain/models/attendance_model.dart';

abstract class AbstractAttendanceRepository {
  Future<Either<Failure, AttendanceModel>> getMyAttendance();

  Future<Either<Failure, AttendanceModel>> checkIn();
}
