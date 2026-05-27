import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/features/settings/domain/models/profile_request_model.dart'
    show ProfileRequestModel;
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';
import 'package:loop/src/features/settings/presentation/providers/profile/profile_state.dart';
import 'package:loop/src/shared/domain/models/user_model.dart';

class ProfileStateNotifier extends StateNotifier<ProfileState> {
  final AbstractSettingRepository _settingRepository;

  ProfileStateNotifier(this._settingRepository)
    : super(const ProfileState.initial());

  Future<void> updateProfile(
    ProfileRequestModel request,
    UserModel user,
  ) async {
    state = const ProfileState.loading();

    final result = await _settingRepository.updateProfile(request, user);

    state = result.match(
      (failure) => ProfileState.error(failure.errorMessage),
      (updatedUser) => ProfileState.success(),
    );
  }
}
