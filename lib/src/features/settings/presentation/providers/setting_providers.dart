import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loop/src/core/providers/init_provider.dart';
import 'package:loop/src/features/settings/data/data_sources/remote/setting_api.dart';
import 'package:loop/src/features/settings/data/repositories/setting_repository_impl.dart';
import 'package:loop/src/features/settings/domain/repositories/abstract_setting_repository.dart';

final settingApiProvider = Provider<SettingApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SettingApi(dio);
});

final settingRepositoryProvider = Provider<AbstractSettingRepository>((ref) {
  final api = ref.watch(settingApiProvider);
  return SettingRepositoryImpl(api);
});
