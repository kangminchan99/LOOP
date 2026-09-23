import 'package:freezed_annotation/freezed_annotation.dart';

part 'ocr_result_model.freezed.dart';
part 'ocr_result_model.g.dart';

@freezed
abstract class OcrResultModel with _$OcrResultModel {
  const factory OcrResultModel({
    // 사진에서 인식한 원본 텍스트
    required String text,
  }) = _OcrResultModel;

  factory OcrResultModel.fromJson(Map<String, dynamic> json) =>
      _$OcrResultModelFromJson(json);
}
