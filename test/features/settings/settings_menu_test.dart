import 'package:flutter_test/flutter_test.dart';
import 'package:loop/src/features/settings/presentation/config/settings_sections.dart';
import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';

void main() {
  List<SettingsMenuId> menus(bool loggedIn, bool admin) =>
      buildSettingsSections(
        isLoggedIn: loggedIn,
        isAdmin: admin,
      ).expand((section) => section.items).toList();

  test('각 권한의 메뉴 ID는 중복되지 않고 빈 섹션이 없다', () {
    for (final loggedIn in [false, true]) {
      for (final admin in [false, true]) {
        final sections = buildSettingsSections(
          isLoggedIn: loggedIn,
          isAdmin: admin,
        );
        final ids = menus(loggedIn, admin);
        expect(ids.toSet().length, ids.length);
        expect(sections.every((section) => section.items.isNotEmpty), isTrue);
      }
    }
  });
  test('OCR과 활동 메뉴는 로그인 상태에서만 노출한다', () {
    for (final id in [
      SettingsMenuId.ocr,
      SettingsMenuId.comments,
      SettingsMenuId.chat,
      SettingsMenuId.attendance,
      SettingsMenuId.notifications,
    ]) {
      expect(menus(false, false), isNot(contains(id)));
      expect(menus(true, false), contains(id));
    }
  });
  test('관리자 메뉴에는 로그인과 관리자 조건이 모두 필요하다', () {
    expect(menus(false, true), isNot(contains(SettingsMenuId.adminWebView)));
    expect(menus(true, false), isNot(contains(SettingsMenuId.serverStatus)));
    expect(
      menus(true, true),
      containsAll([SettingsMenuId.adminWebView, SettingsMenuId.serverStatus]),
    );
  });
  test('Bluetooth와 공통 설정의 기존 비로그인 접근은 유지한다', () {
    expect(
      menus(false, false),
      containsAll([
        SettingsMenuId.bluetooth,
        SettingsMenuId.theme,
        SettingsMenuId.language,
      ]),
    );
  });
  test('미구현 메뉴는 기능이 있는 것처럼 실행되지 않는다', () {
    expect(SettingsMenuId.notificationSettings.isImplemented, isFalse);
    expect(SettingsMenuId.terms.isImplemented, isFalse);
    expect(SettingsMenuId.ocr.isImplemented, isTrue);
  });
}
