// 사진 선택 담당
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loop/src/features/ocr/data/data_sources/local/ocr_image_local_data_source.dart';
import 'package:loop/src/features/ocr/data/data_sources/local/text_recognition_local_data_source.dart';
import 'package:loop/src/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:loop/src/features/ocr/domain/repositories/abstract_ocr_repository.dart';
import 'package:loop/src/features/ocr/domain/usecases/recognize_image_text_usecase.dart';
import 'package:loop/src/features/ocr/presentation/providers/ocr_notifier.dart';
import 'package:loop/src/features/ocr/presentation/providers/ocr_state.dart';

final ocrImageLocalDataSourceProvider =
    Provider.autoDispose<OcrImageLocalDataSource>((ref) {
      return OcrImageLocalDataSource(ImagePicker());
    });

// 이미지에서 텍스트를 인식한다.
final textRecognitionLocalDataSourceProvider =
    Provider.autoDispose<TextRecognitionLocalDataSource>((ref) {
      return TextRecognitionLocalDataSource();
    });

// 두 DataSource를 연결하고 오류를 Failure로 변환한다.
final ocrRepositoryProvider = Provider.autoDispose<AbstractOcrRepository>((
  ref,
) {
  return OcrRepositoryImpl(
    imageDataSource: ref.watch(ocrImageLocalDataSourceProvider),
    textDataSource: ref.watch(textRecognitionLocalDataSourceProvider),
  );
});

// 텍스트 인식 기능을 실행한다.
final recognizeImageTextUseCaseProvider =
    Provider.autoDispose<RecognizeImageTextUseCase>((ref) {
      return RecognizeImageTextUseCase(ref.watch(ocrRepositoryProvider));
    });

// OCR 화면의 상태와 동작을 관리한다.
final ocrNotifierProvider =
    StateNotifierProvider.autoDispose<OcrNotifier, OcrState>((ref) {
      return OcrNotifier(
        repository: ref.watch(ocrRepositoryProvider),
        recognizeImageTextUseCase: ref.watch(recognizeImageTextUseCaseProvider),
      );
    });
