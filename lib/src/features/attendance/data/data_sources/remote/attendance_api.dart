import 'package:dio/dio.dart';

class AttendanceApi {
  final Dio _dio;
  AttendanceApi(this._dio);

  Future<Response<Map<String, dynamic>>> getMyAttendance() async {
    return _dio.get<Map<String, dynamic>>('/attendance/me');
  }

  Future<Response<Map<String, dynamic>>> checkIn() async {
    return _dio.post<Map<String, dynamic>>('/attendance/check-in');
  }
}
