import 'package:equatable/equatable.dart';

/// 도메인 계층에서 사용하는 실패(Failure) 추상 클래스.
///
/// Repository 구현체에서 예외(Exception)를 이 타입으로 변환해 반환합니다.
/// Presentation 계층은 구체적인 예외 대신 [Failure]에만 의존합니다.
abstract class Failure extends Equatable {
  final String errorMessage;

  const Failure(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

/// 서버(API) 통신 오류.
/// [statusCode]는 HTTP 상태 코드이며, 네트워크 단절 등으로 응답이 없을 경우 null입니다.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure(super.errorMessage, this.statusCode);
}

/// Dio CancelToken으로 요청이 취소된 경우의 오류.
class CancelTokenFailure extends Failure {
  final int? statusCode;

  const CancelTokenFailure(super.errorMessage, this.statusCode);
}
