import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop/src/core/localization/locale_provider.dart';
import 'package:loop/src/core/theme/theme_mode_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('기존 저장 키로 언어와 테마를 복원한다', () async {
    SharedPreferences.setMockInitialValues({
      'app_locale': 'en',
      'theme_mode': 'dark',
    });
    final locale = LocaleNotifier();
    final theme = ThemeModeNotifier();
    addTearDown(locale.dispose);
    addTearDown(theme.dispose);
    await Future.wait([locale.ready, theme.ready]);
    expect(locale.state, const Locale('en'));
    expect(theme.state, ThemeMode.dark);
  });
  test('지원하지 않는 저장 언어는 한국어로 복원한다', () async {
    SharedPreferences.setMockInitialValues({'app_locale': 'unknown'});
    final notifier = LocaleNotifier();
    addTearDown(notifier.dispose);
    await notifier.ready;
    expect(notifier.state, const Locale('ko'));
  });
  test('초기 로드와 연속 저장이 경합해도 마지막 선택을 보존한다', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final preferences = await SharedPreferences.getInstance();
    final gate = Completer<SharedPreferences>();
    final notifier = ThemeModeNotifier(loadPreferences: () => gate.future);
    addTearDown(notifier.dispose);
    final first = notifier.changeThemeMode(ThemeMode.light);
    final last = notifier.changeThemeMode(ThemeMode.system);
    gate.complete(preferences);
    await Future.wait([first, last]);
    expect(notifier.state, ThemeMode.system);
    expect(preferences.getString('theme_mode'), 'system');
  });
  test('저장 실패는 이전 값을 유지하고 다음 저장은 다시 가능하다', () async {
    final preferences = await SharedPreferences.getInstance();
    var fail = false;
    final notifier = LocaleNotifier(
      loadPreferences: () async {
        if (fail) throw StateError('storage unavailable');
        return preferences;
      },
    );
    addTearDown(notifier.dispose);
    await notifier.ready;
    fail = true;
    await expectLater(
      notifier.changeLocale(const Locale('en')),
      throwsStateError,
    );
    expect(notifier.state, const Locale('ko'));
    fail = false;
    await notifier.changeLocale(const Locale('en'));
    expect(notifier.state, const Locale('en'));
  });
  test('초기 로드 중 dispose되어도 상태를 변경하지 않는다', () async {
    final gate = Completer<SharedPreferences>();
    final notifier = LocaleNotifier(loadPreferences: () => gate.future);
    notifier.dispose();
    gate.complete(await SharedPreferences.getInstance());
    await notifier.ready;
  });
}
