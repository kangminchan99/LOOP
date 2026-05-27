import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_request_model.freezed.dart';
part 'profile_request_model.g.dart';

@freezed
abstract class ProfileRequestModel with _$ProfileRequestModel {
  const factory ProfileRequestModel({String? image}) = _ProfileRequestModel;

  factory ProfileRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileRequestModelFromJson(json);
}
