import 'package:dio/dio.dart';

/// DioException에서 사람이 읽을 수 있는 에러 메시지를 추출합니다.
///
/// 우선순위:
///   1. 서버가 반환한 JSON body의 'message' 필드
///   2. 서버가 반환한 JSON body의 'error' 필드
///   3. DioExceptionType에 따른 기본 메시지
String extractDioErrorMessage(DioException error) {
  // 서버 응답이 있는 경우 body에서 메시지 추출 시도
  if (error.response != null) {
    final data = error.response!.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;

      final errorField = data['error'];
      if (errorField is String && errorField.isNotEmpty) return errorField;
    }
  }

  // 서버 응답 없는 경우: DioExceptionType 기반 메시지
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
      return '서버 연결 시간이 초과됐습니다. 네트워크 상태를 확인해주세요.';
    case DioExceptionType.sendTimeout:
      return '요청 전송 시간이 초과됐습니다. 잠시 후 다시 시도해주세요.';
    case DioExceptionType.receiveTimeout:
      return '응답 수신 시간이 초과됐습니다. 잠시 후 다시 시도해주세요.';
    case DioExceptionType.connectionError:
      return '네트워크에 연결할 수 없습니다. 인터넷 연결을 확인해주세요.';
    case DioExceptionType.cancel:
      return '요청이 취소됐습니다.';
    case DioExceptionType.badCertificate:
      return '보안 인증서 오류가 발생했습니다.';
    case DioExceptionType.badResponse:
      final statusCode = error.response?.statusCode;
      return _messageFromStatusCode(statusCode);
    case DioExceptionType.unknown:
      return error.message ?? '알 수 없는 오류가 발생했습니다.';
  }
}

String _messageFromStatusCode(int? statusCode) {
  switch (statusCode) {
    case 400:
      return '잘못된 요청입니다.';
    case 401:
      return '인증이 필요합니다. 다시 로그인해주세요.';
    case 403:
      return '접근 권한이 없습니다.';
    case 404:
      return '요청한 리소스를 찾을 수 없습니다.';
    case 409:
      return '요청이 충돌했습니다. 잠시 후 다시 시도해주세요.';
    case 422:
      return '입력값이 올바르지 않습니다.';
    case 429:
      return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
    case 500:
    case 502:
    case 503:
      return '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
    default:
      return '오류가 발생했습니다. (${statusCode ?? '알 수 없음'})';
  }
}
