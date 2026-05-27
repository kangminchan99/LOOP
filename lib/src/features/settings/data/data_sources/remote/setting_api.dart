import 'package:dio/dio.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart';

class SettingApi {
  final Dio _dio;
  SettingApi(this._dio);

  Future<Response<Map<String, dynamic>>> updateProfile(
    ProfileRequestModel request,
  ) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(request.image!),
    });
    return _dio.post<Map<String, dynamic>>(
      '/upload/profile-image',
      data: formData,
    );
  }
}
