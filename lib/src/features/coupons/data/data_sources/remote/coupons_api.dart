import 'package:dio/dio.dart';

class CouponsApi {
  const CouponsApi(this._dio);

  final Dio _dio;

  Future<Response<Map<String, dynamic>>> getCouponEvents({
    int limit = 20,
    String? cursor,
    CancelToken? cancleToken,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/coupon-events',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      cancelToken: cancleToken,
    );
  }

  // 특정 쿠폰 이벤트의 상세 정보 조회
  Future<Response<Map<String, dynamic>>> getCouponEvent({
    required int eventId,
    CancelToken? cancelToken,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/coupon-events/$eventId',
      cancelToken: cancelToken,
    );
  }

  // 해당 이벤트에서 본인 쿠폰 발급
  Future<Response<Map<String, dynamic>>> issueCoupon({required int eventId}) {
    return _dio.put<Map<String, dynamic>>('/coupon-events/$eventId/my-coupon');
  }

  // 해당 이벤트에서 내가 발급받은 쿠폰 조회
  Future<Response<Map<String, dynamic>>> getMyCoupon({
    required int eventId,
    CancelToken? cancelToken,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/coupon-events/$eventId/my-coupon',
      cancelToken: cancelToken,
    );
  }

  // 내가 발급받은 쿠폰 목록 조회
  Future<Response<Map<String, dynamic>>> getMyCoupons({
    int limit = 20,
    String? cursor,
    CancelToken? cancelToken,
  }) {
    return _dio.get<Map<String, dynamic>>(
      '/coupons/me',
      queryParameters: {'limit': limit, if (cursor != null) 'cursor': cursor},
      cancelToken: cancelToken,
    );
  }
}
