import 'package:loop/src/features/attendance/domain/models/attendance_model.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class CheckInAttendanceResult {
  const CheckInAttendanceResult({required this.attendance, required this.user});

  final AttendanceModel attendance;
  final UserModel user;
}
