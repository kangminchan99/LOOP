import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/network/error/failures.dart';
import 'package:loop/src/core/network/error/ocr_failure.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_image_source.dart';
import 'package:loop/src/features/ocr/domain/repositories/abstract_ocr_repository.dart';
import 'package:loop/src/features/ocr/domain/usecases/recognize_image_text_usecase.dart';
import 'package:loop/src/features/ocr/presentation/providers/ocr_state.dart';

class OcrNotifier extends StateNotifier<OcrState> {
  final AbstractOcrRepository _repository;
  final RecognizeImageTextUseCase _recognizeImageTextUseCase;

  OcrNotifier({
    required AbstractOcrRepository repository,
    required RecognizeImageTextUseCase recognizeImageTextUseCase,
  }) : _repository = repository,
       _recognizeImageTextUseCase = recognizeImageTextUseCase,
       super(const OcrState());

  Future<void> selectImage({required OcrImageSource source}) async {
    // 처리 중에는 중복 실행하지 않는다.
    if (!mounted || state.isBusy) return;

    // 사진 선택을 취소하면 이전 화면으로 복구한다.
    final previousState = state;

    state = state.copyWith(status: OcrStatus.selecting, failureCode: null);

    final selection = await _repository.pickImage(source: source);

    // 화면을 나가 Notifier가 해제됐다면 결과를 반영하지 않는다.
    if (!mounted) return;

    await selection.fold<Future<void>>(
      (failure) async {
        state = previousState.copyWith(
          status: OcrStatus.failure,
          failureCode: _failureCode(
            failure,
            OcrFailureCode.imageSelectionFailed,
          ),
        );
      },
      (imagePath) async {
        if (imagePath == null) {
          state = previousState;
          return;
        }

        // 새 사진을 표시하고 이전 인식 결과를 지운다.
        state = OcrState(status: OcrStatus.recognizing, imagePath: imagePath);

        await _recognizeText(imagePath);
      },
    );
  }

  Future<void> _recognizeText(String imagePath) async {
    final recognition = await _recognizeImageTextUseCase(imagePath: imagePath);

    if (!mounted) return;

    recognition.fold<void>(
      (failure) {
        state = state.copyWith(
          status: OcrStatus.failure,
          failureCode: _failureCode(failure, OcrFailureCode.recognitionFailed),
        );
      },
      (result) {
        // 공백만 인식한 경우도 '인식 결과 없음'으로 처리한다.
        final isEmpty = result.text.trim().isEmpty;

        state = state.copyWith(
          status: isEmpty ? OcrStatus.empty : OcrStatus.success,
          result: result,
          failureCode: null,
        );
      },
    );
  }

  // 일반 Failure가 전달되더라도 OCR 화면에서 처리할 수 있게 한다.
  OcrFailureCode _failureCode(Failure failure, OcrFailureCode fallback) {
    return failure is OcrFailure ? failure.code : fallback;
  }
}
