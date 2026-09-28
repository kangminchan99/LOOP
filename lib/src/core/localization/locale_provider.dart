import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop/src/core/preferences/persisted_preference_notifier.dart';

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

class LocaleNotifier extends PersistedPreferenceNotifier<Locale> {
  LocaleNotifier({Future<SharedPreferences> Function()? loadPreferences})
    : super(
        const Locale('ko'),
        storageKey: 'app_locale',
        loadPreferences: loadPreferences,
      );

  @override
  Locale decode(String? value) => Locale(value == 'en' ? 'en' : 'ko');
  @override
  String encode(Locale value) => value.languageCode;
  Future<void> changeLocale(Locale value) {
    if (!const ['ko', 'en'].contains(value.languageCode)) {
      return Future.error(ArgumentError.value(value, 'locale'));
    }
    return save(Locale(value.languageCode));
  }
}
