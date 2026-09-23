import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/core/network/error/ocr_failure.dart';
import 'package:loop/src/features/ocr/domain/models/ocr_result_model.dart';

part 'ocr_state.freezed.dart';

// 사진 선택과 텍스트 인식의 진행 상태
enum OcrStatus { idle, selecting, recognizing, success, empty, failure }

@freezed
abstract class OcrState with _$OcrState {
  const OcrState._();

  const factory OcrState({
    // 현재 진행 상태
    @Default(OcrStatus.idle) OcrStatus status,

    // 미리보기에 사용할 사진 경로
    String? imagePath,

    // 사진에서 추출한 텍스트
    OcrResultModel? result,

    // 화면에서 오류 안내를 결정할 때 사용
    OcrFailureCode? failureCode,
  }) = _OcrState;

  // 처리 중에는 사진 선택 버튼의 중복 실행을 막는다.
  bool get isBusy =>
      status == OcrStatus.selecting || status == OcrStatus.recognizing;
}
