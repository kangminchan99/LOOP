import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_image_source.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_result_model.dart';

abstract class AbstractOcrRepository {
  // 사진을 선택하고 임시 파일 경로를 반환.
  // 사용자가 선택을 취소하면 Right(null)을 반환.
  Future<Either<Failure, String?>> pickImage({required OcrImageSource source});

  /// 선택한 이미지에서 텍스트를 추출한다.
  Future<Either<Failure, OcrResultModel>> recognizeText({
    required String imagePath,
  });
}
