import 'package:freezed_annotation/freezed_annotation.dart';

part 'sign_up_request_model.freezed.dart';
part 'sign_up_request_model.g.dart';

@freezed
abstract class SignUpRequestModel with _$SignUpRequestModel {
  const factory SignUpRequestModel({
    required String email,
    required String password,
    required String nickname,
  }) = _SignUpRequestModel;

  factory SignUpRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpRequestModelFromJson(json);
}
