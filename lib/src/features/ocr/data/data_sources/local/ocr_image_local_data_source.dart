import 'package:image_picker/image_picker.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_image_source.dart';

class OcrImageLocalDataSource {
  final ImagePicker _picker;

  OcrImageLocalDataSource(this._picker);

  Future<String?> pickImage({required OcrImageSource source}) async {
    // 앱 자체 타입을 image_picker의 타입으로 변환한다.
    final pickerSource = switch (source) {
      OcrImageSource.camera => ImageSource.camera,
      OcrImageSource.gallery => ImageSource.gallery,
    };

    // 선택한 경로에 따라 카메라 또는 사진 선택 화면을 연다.
    final image = await _picker.pickImage(
      source: pickerSource,

      // OCR에 불필요한 전체 메타데이터 조회를 요청하지 않는다.
      requestFullMetadata: false,
    );

    // 선택 취소는 null, 선택 성공은 이미지 파일 경로를 반환한다.
    return image?.path;
  }
}
