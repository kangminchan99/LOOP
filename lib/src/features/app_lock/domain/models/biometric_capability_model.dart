import 'package:freezed_annotation/freezed_annotation.dart';

part 'biometric_capability_model.freezed.dart';
part 'biometric_capability_model.g.dart';

@freezed
abstract class BiometricCapabilityModel with _$BiometricCapabilityModel {
  const factory BiometricCapabilityModel({
    // 기기가 생체 인증을 지원하는지
    required bool isSupported,

    // 사용자가 지문이나 얼굴을 등록했는지
    required bool isEnrolled,
  }) = _BiometricCapabilityModel;

  factory BiometricCapabilityModel.fromJson(Map<String, dynamic> json) =>
      _$BiometricCapabilityModelFromJson(json);
}
