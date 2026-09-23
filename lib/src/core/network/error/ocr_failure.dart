import 'failures.dart';

/// OCR 작업에서 발생할 수 있는 오류 종류
enum OcrFailureCode {
  unsupportedPlatform, // 지원하지 않는 플랫폼
  permissionDenied, // 카메라·사진 접근 권한 거부
  imageSelectionFailed, // 사진 선택 실패
  invalidImage, // 파일이 없거나 읽을 수 없는 이미지
  recognitionFailed, // 글자 인식 처리 실패
}

class OcrFailure extends Failure {
  final OcrFailureCode code;

  const OcrFailure({required this.code, required String message})
    : super(message);

  // 메시지가 같더라도 오류 코드가 다르면 서로 다른 오류로 판단한다.
  @override
  List<Object?> get props => [code, errorMessage];
}
