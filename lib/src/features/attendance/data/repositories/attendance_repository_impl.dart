import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/attendance/data/data_sources/remote/attendance_api.dart';
import 'package:loop/src/features/attendance/domain/models/attendance_model.dart';
import 'package:loop/src/features/attendance/domain/repositories/abstract_attendance_repository.dart';

class AttendanceRepositoryImpl implements AbstractAttendanceRepository {
  final AttendanceApi _attendanceApi;
  AttendanceRepositoryImpl(this._attendanceApi);
  @override
  Future<Either<Failure, AttendanceModel>> checkIn() async {
    try {
      final response = await _attendanceApi.checkIn();

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(AttendanceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }

  @override
  Future<Either<Failure, AttendanceModel>> getMyAttendance() async {
    try {
      final response = await _attendanceApi.getMyAttendance();

      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', 500));
      }

      return Right(AttendanceModel.fromJson(data));
    } on DioException catch (e) {
      return Left(
        ServerFailure(extractDioErrorMessage(e), e.response?.statusCode),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString(), null));
    }
  }
}
