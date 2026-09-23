import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:fpdart/fpdart.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/core/network/error/ocr_failure.dart';
import 'package:loop/src/features/ocr/data/data_sources/local/ocr_image_local_data_source.dart';
import 'package:loop/src/features/ocr/data/data_sources/local/text_recognition_local_data_source.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_image_source.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_result_model.dart';
import 'package:loop/src/features/ocr/domain/repositories/abstract_ocr_repository.dart';

class OcrRepositoryImpl implements AbstractOcrRepository {
  final OcrImageLocalDataSource _imageDataSource;
  final TextRecognitionLocalDataSource _textDataSource;

  OcrRepositoryImpl({
    required OcrImageLocalDataSource imageDataSource,
    required TextRecognitionLocalDataSource textDataSource,
  }) : _imageDataSource = imageDataSource,
       _textDataSource = textDataSource;

  // 현재 OCR은 Android와 iOS에서만 지원한다.
  bool get _isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const _unsupportedPlatformFailure = OcrFailure(
    code: OcrFailureCode.unsupportedPlatform,
    message: '이 기기에서는 텍스트 인식을 지원하지 않습니다.',
  );

  @override
  Future<Either<Failure, String?>> pickImage({
    required OcrImageSource source,
  }) async {
    if (!_isSupportedPlatform) {
      return const Left(_unsupportedPlatformFailure);
    }

    try {
      final imagePath = await _imageDataSource.pickImage(source: source);

      // 선택 취소(null)는 오류가 아니다.
      return Right(imagePath);
    } on PlatformException catch (error) {
      return Left(_mapImageSelectionError(error));
    } catch (_) {
      return const Left(
        OcrFailure(
          code: OcrFailureCode.imageSelectionFailed,
          message: '사진을 선택하지 못했습니다.',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, OcrResultModel>> recognizeText({
    required String imagePath,
  }) async {
    if (!_isSupportedPlatform) {
      return const Left(_unsupportedPlatformFailure);
    }

    // 이미지 경로가 없으면 네이티브 OCR을 호출하지 않는다.
    if (imagePath.trim().isEmpty) {
      return const Left(
        OcrFailure(
          code: OcrFailureCode.invalidImage,
          message: '인식할 사진을 선택해 주세요.',
        ),
      );
    }

    try {
      final text = await _textDataSource.recognizeText(imagePath: imagePath);

      // 인식된 글자가 없는 경우에도 정상 결과로 반환한다.
      return Right(OcrResultModel(text: text));
    } catch (_) {
      return const Left(
        OcrFailure(
          code: OcrFailureCode.recognitionFailed,
          message: '사진의 텍스트를 인식하지 못했습니다.',
        ),
      );
    }
  }

  Failure _mapImageSelectionError(PlatformException error) {
    switch (error.code) {
      case 'camera_access_denied':
      case 'camera_access_restricted':
      case 'photo_access_denied':
      case 'photo_access_restricted':
        return const OcrFailure(
          code: OcrFailureCode.permissionDenied,
          message: '사진 또는 카메라 접근 권한을 확인해 주세요.',
        );

      case 'invalid_image':
        return const OcrFailure(
          code: OcrFailureCode.invalidImage,
          message: '사용할 수 없는 이미지입니다.',
        );

      default:
        return const OcrFailure(
          code: OcrFailureCode.imageSelectionFailed,
          message: '사진을 선택하지 못했습니다.',
        );
    }
  }
}
