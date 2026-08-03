import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'Loop'**
  String get appTitle;

  /// No description provided for @loginStartTitle.
  ///
  /// In ko, this message translates to:
  /// **'시작하기'**
  String get loginStartTitle;

  /// No description provided for @loginStartDescription.
  ///
  /// In ko, this message translates to:
  /// **'나와 비슷한 생각을 가진 사람들과 가볍게 연결돼요.'**
  String get loginStartDescription;

  /// No description provided for @loginIdOrEmailHint.
  ///
  /// In ko, this message translates to:
  /// **'아이디 또는 이메일'**
  String get loginIdOrEmailHint;

  /// No description provided for @loginPasswordHint.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get loginPasswordHint;

  /// No description provided for @loginButton.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get loginButton;

  /// No description provided for @loginWithKakao.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 간편 로그인'**
  String get loginWithKakao;

  /// No description provided for @loginWithGoogle.
  ///
  /// In ko, this message translates to:
  /// **'구글로 간편 로그인'**
  String get loginWithGoogle;

  /// No description provided for @signUpQuestion.
  ///
  /// In ko, this message translates to:
  /// **'아직 계정이 없나요?'**
  String get signUpQuestion;

  /// No description provided for @signUp.
  ///
  /// In ko, this message translates to:
  /// **'회원가입'**
  String get signUp;

  /// No description provided for @appShellHome.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get appShellHome;

  /// No description provided for @appShellMyPage.
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get appShellMyPage;

  /// No description provided for @settingsAccount.
  ///
  /// In ko, this message translates to:
  /// **'계정'**
  String get settingsAccount;

  /// No description provided for @settingsCommunity.
  ///
  /// In ko, this message translates to:
  /// **'커뮤니티'**
  String get settingsCommunity;

  /// No description provided for @settingsAppSettings.
  ///
  /// In ko, this message translates to:
  /// **'앱 설정'**
  String get settingsAppSettings;

  /// No description provided for @settingsSupport.
  ///
  /// In ko, this message translates to:
  /// **'지원'**
  String get settingsSupport;

  /// No description provided for @settingsMyComments.
  ///
  /// In ko, this message translates to:
  /// **'내 댓글'**
  String get settingsMyComments;

  /// No description provided for @settingsAttendanceCheck.
  ///
  /// In ko, this message translates to:
  /// **'출석 체크'**
  String get settingsAttendanceCheck;

  /// No description provided for @settingsNotificationList.
  ///
  /// In ko, this message translates to:
  /// **'알림 목록'**
  String get settingsNotificationList;

  /// No description provided for @settingsBlockedUsers.
  ///
  /// In ko, this message translates to:
  /// **'차단한 사용자'**
  String get settingsBlockedUsers;

  /// No description provided for @settingsSavedPosts.
  ///
  /// In ko, this message translates to:
  /// **'저장한 글'**
  String get settingsSavedPosts;

  /// No description provided for @settingsNotificationSettings.
  ///
  /// In ko, this message translates to:
  /// **'알림 설정'**
  String get settingsNotificationSettings;

  /// No description provided for @settingsDisplayMode.
  ///
  /// In ko, this message translates to:
  /// **'화면 모드'**
  String get settingsDisplayMode;

  /// No description provided for @settingsLanguage.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguage;

  /// No description provided for @settingsNotice.
  ///
  /// In ko, this message translates to:
  /// **'공지사항'**
  String get settingsNotice;

  /// No description provided for @settingsContact.
  ///
  /// In ko, this message translates to:
  /// **'문의하기'**
  String get settingsContact;

  /// No description provided for @settingsTermsPrivacy.
  ///
  /// In ko, this message translates to:
  /// **'약관 및 개인정보 처리방침'**
  String get settingsTermsPrivacy;

  /// No description provided for @settingsOn.
  ///
  /// In ko, this message translates to:
  /// **'켜짐'**
  String get settingsOn;

  /// No description provided for @settingsSystem.
  ///
  /// In ko, this message translates to:
  /// **'시스템'**
  String get settingsSystem;

  /// No description provided for @settingsKorean.
  ///
  /// In ko, this message translates to:
  /// **'한국어'**
  String get settingsKorean;

  /// No description provided for @settingsEnglish.
  ///
  /// In ko, this message translates to:
  /// **'English'**
  String get settingsEnglish;

  /// No description provided for @settingsLoginRequiredTitle.
  ///
  /// In ko, this message translates to:
  /// **'로그인이 필요해요'**
  String get settingsLoginRequiredTitle;

  /// No description provided for @settingsLoginRequiredDescription.
  ///
  /// In ko, this message translates to:
  /// **'글 작성, 저장한 글, 내 댓글\n관리는 로그인 후 이용할 수 있어요.'**
  String get settingsLoginRequiredDescription;

  /// No description provided for @settingsLoginSignup.
  ///
  /// In ko, this message translates to:
  /// **'로그인 / 회원가입'**
  String get settingsLoginSignup;

  /// No description provided for @settingsLogout.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutComplete.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃 되었습니다.'**
  String get settingsLogoutComplete;

  /// No description provided for @settingsUploadFailed.
  ///
  /// In ko, this message translates to:
  /// **'업로드 실패'**
  String get settingsUploadFailed;

  /// No description provided for @settingsNoProfileImage.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get settingsNoProfileImage;

  /// No description provided for @settingsNoEmail.
  ///
  /// In ko, this message translates to:
  /// **'이메일 없음'**
  String get settingsNoEmail;

  /// No description provided for @settingsPoints.
  ///
  /// In ko, this message translates to:
  /// **'포인트'**
  String get settingsPoints;

  /// No description provided for @settingsEdit.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get settingsEdit;

  /// No description provided for @languageDialogTitle.
  ///
  /// In ko, this message translates to:
  /// **'언어 설정'**
  String get languageDialogTitle;

  /// No description provided for @languageDialogClose.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get languageDialogClose;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
