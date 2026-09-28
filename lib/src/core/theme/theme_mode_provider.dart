import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop/src/core/preferences/persisted_preference_notifier.dart';

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends PersistedPreferenceNotifier<ThemeMode> {
  ThemeModeNotifier({Future<SharedPreferences> Function()? loadPreferences})
    : super(
        ThemeMode.system,
        storageKey: 'theme_mode',
        loadPreferences: loadPreferences,
      );

  @override
  ThemeMode decode(String? value) => switch (value) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
  @override
  String encode(ThemeMode value) => value.name;
  Future<void> changeThemeMode(ThemeMode value) => save(value);
}
