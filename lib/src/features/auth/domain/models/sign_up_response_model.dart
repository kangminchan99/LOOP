import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

part 'sign_up_response_model.freezed.dart';
part 'sign_up_response_model.g.dart';

@freezed
abstract class SignUpResponseModel with _$SignUpResponseModel {
  const factory SignUpResponseModel({
    required UserModel user,
    required String accessToken,
    required String refreshToken,
  }) = _SignUpResponseModel;

  factory SignUpResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SignUpResponseModelFromJson(json);
}
