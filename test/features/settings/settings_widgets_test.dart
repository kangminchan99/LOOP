import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:loop/l10n/app_localizations.dart';
import 'package:loop/src/features/settings/presentation/models/settings_menu.dart';
import 'package:loop/src/features/settings/presentation/widgets/settings_menu_tile.dart';
import 'package:loop/src/features/settings/presentation/widgets/preference_choice_dialog.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  Widget app(Widget child) => ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  testWidgets('미구현 메뉴는 준비 중으로 표시하고 클릭되지 않는다', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      app(
        SettingsMenuTile(
          id: SettingsMenuId.notificationSettings,
          onTap: () => calls++,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Coming soon'), findsOneWidget);
    await tester.tap(find.byType(ListTile));
    expect(calls, 0);
  });
  testWidgets('테마 표시값은 저장된 실제 설정을 따른다', (tester) async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    await tester.pumpWidget(
      app(SettingsMenuTile(id: SettingsMenuId.theme, onTap: () {})),
    );
    await tester.pumpAndSettle();
    expect(find.text('Dark'), findsOneWidget);
  });
  testWidgets('좁은 화면과 큰 글씨에서 메뉴가 넘치지 않는다', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      app(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: SingleChildScrollView(
            child: SettingsMenuTile(id: SettingsMenuId.terms, onTap: () {}),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('저장 실패를 다이얼로그 안에 표시한다', (tester) async {
    await tester.pumpWidget(
      app(
        PreferenceChoiceDialog<int>(
          title: 'Theme',
          values: const [0, 1],
          selected: 0,
          label: (value) => 'Choice $value',
          onChanged: (_) async => throw StateError('storage'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choice 1'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not save your settings. Please try again.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
