import 'package:dio/dio.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/dio_error_handler.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/coupons/data/data_sources/remote/coupons_api.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_list_model.dart';
import 'package:loop/src/features/coupons/domain/models/coupon_event_model.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_list_model.dart';
import 'package:loop/src/features/coupons/domain/models/user_coupon_model.dart';
import 'package:loop/src/features/coupons/domain/repositories/abstract_coupons_repository.dart';

class CouponsRepositoryImpl implements AbstractCouponsRepository {
  const CouponsRepositoryImpl(this._api);

  final CouponsApi _api;

  @override
  Future<Either<Failure, CouponEventListModel>> getCouponEvents({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      // 1. 서버에 목록 조회 요청
      final response = await _api.getCouponEvents(limit: limit, cursor: cursor);

      // 2. 응답 본문 확인
      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', null));
      }

      // 3. JSON을 모델로 변환하여 성공 반환
      return Right(CouponEventListModel.fromJson(data));
    } on DioException catch (e) {
      // HTTP·연결 오류를 앱의 실패 타입으로 변환
      return Left(_mapDioFailure(e));
    } on FormatException {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    }
  }

  // 다른 API 메서드에서도 사용할 통신 오류 변환
  Failure _mapDioFailure(DioException error) {
    final message = extractDioErrorMessage(error);

    switch (error.type) {
      case DioExceptionType.cancel:
        return CancelTokenFailure(message, error.response?.statusCode);

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return NetworkFailure(message);

      default:
        return ServerFailure(message, error.response?.statusCode);
    }
  }

  @override
  Future<Either<Failure, CouponEventModel>> getCouponEvent({
    required int eventId,
  }) async {
    try {
      // 1. 해당 이벤트 상세 조회
      final response = await _api.getCouponEvent(eventId: eventId);

      // 2. 응답 본문 확인
      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', null));
      }

      // 3. JSON을 이벤트 모델로 변환
      return Right(CouponEventModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } on FormatException {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    }
  }

  @override
  @override
  Future<Either<Failure, UserCouponModel>> issueCoupon({
    required int eventId,
  }) async {
    try {
      // 1. 본인 쿠폰 발급 요청
      final response = await _api.issueCoupon(eventId: eventId);

      // 2. 응답 본문 확인
      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('발급 결과를 확인할 수 없습니다.', null));
      }

      // 3. 최초 발급(201)과 기존 쿠폰 반환(200)을 동일하게 처리
      return Right(UserCouponModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } on FormatException {
      return const Left(ServerFailure('발급 결과의 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('발급 결과의 데이터 형식이 올바르지 않습니다.', null));
    }
  }

  @override
  Future<Either<Failure, UserCouponModel?>> getMyCoupon({
    required int eventId,
  }) async {
    try {
      // 1. 해당 이벤트의 본인 쿠폰 조회
      final response = await _api.getMyCoupon(eventId: eventId);

      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', null));
      }

      // 2. 발급된 쿠폰 반환
      return Right(UserCouponModel.fromJson(data));
    } on DioException catch (e) {
      final data = e.response?.data;

      // 3. 서버가 명확히 "미발급"을 반환한 경우만 null 처리
      if (e.response?.statusCode == 404 &&
          data is Map<String, dynamic> &&
          data['code'] == 'MY_COUPON_NOT_FOUND') {
        return const Right(null);
      }

      // 이벤트 없음, 인증 실패, 네트워크 오류 등은 실패로 전달
      return Left(_mapDioFailure(e));
    } on FormatException {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    }
  }

  @override
  Future<Either<Failure, UserCouponListModel>> getMyCoupons({
    int limit = 20,
    String? cursor,
  }) async {
    try {
      // 1. 내 쿠폰 목록 조회
      final response = await _api.getMyCoupons(limit: limit, cursor: cursor);

      // 2. 응답 본문 확인
      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('응답 데이터가 없습니다.', null));
      }

      // 3. 쿠폰 목록과 페이지네이션 정보를 모델로 변환
      return Right(UserCouponListModel.fromJson(data));
    } on DioException catch (e) {
      return Left(_mapDioFailure(e));
    } on FormatException {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    } on TypeError {
      return const Left(ServerFailure('응답 데이터 형식이 올바르지 않습니다.', null));
    }
  }
}
