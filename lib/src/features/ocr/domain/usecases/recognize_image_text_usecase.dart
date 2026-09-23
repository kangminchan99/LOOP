import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_result_model.dart';
import 'package:loop/src/features/ocr/domain/repositories/abstract_ocr_repository.dart';

class RecognizeImageTextUseCase {
  final AbstractOcrRepository _repository;

  RecognizeImageTextUseCase(this._repository);

  // 선택한 이미지의 텍스트 인식을 요청한다.
  Future<Either<Failure, OcrResultModel>> call({required String imagePath}) {
    return _repository.recognizeText(imagePath: imagePath);
  }
}
