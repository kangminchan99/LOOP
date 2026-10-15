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

  /// No description provided for @postsConnectionUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'서버에 연결할 수 없어요. 이미 불러온 게시글만 볼 수 있어요.'**
  String get postsConnectionUnavailable;

  /// No description provided for @postsRefreshFailed.
  ///
  /// In ko, this message translates to:
  /// **'게시글을 갱신하지 못했어요. 다시 시도해주세요.'**
  String get postsRefreshFailed;

  /// No description provided for @postsShowingCache.
  ///
  /// In ko, this message translates to:
  /// **'기기에 저장된 게시글을 보여주고 있어요.'**
  String get postsShowingCache;

  /// No description provided for @postsRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get postsRetry;

  /// No description provided for @postsRefresh.
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get postsRefresh;

  /// No description provided for @appLockTitle.
  ///
  /// In ko, this message translates to:
  /// **'앱 잠금'**
  String get appLockTitle;

  /// No description provided for @appLockDescription.
  ///
  /// In ko, this message translates to:
  /// **'앱을 사용하려면 본인 인증을 진행해주세요.'**
  String get appLockDescription;

  /// No description provided for @appLockChecking.
  ///
  /// In ko, this message translates to:
  /// **'인증 상태를 확인하고 있어요.'**
  String get appLockChecking;

  /// No description provided for @appLockUnlock.
  ///
  /// In ko, this message translates to:
  /// **'잠금 해제'**
  String get appLockUnlock;

  /// No description provided for @appLockRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 확인'**
  String get appLockRetry;

  /// No description provided for @appLockError.
  ///
  /// In ko, this message translates to:
  /// **'인증 또는 설정 확인에 문제가 발생했습니다. 다시 시도해주세요.'**
  String get appLockError;

  /// No description provided for @appLockReason.
  ///
  /// In ko, this message translates to:
  /// **'앱 잠금을 해제하려면 인증해주세요.'**
  String get appLockReason;

  /// No description provided for @settingsAppLock.
  ///
  /// In ko, this message translates to:
  /// **'생체 인증 앱 잠금'**
  String get settingsAppLock;

  /// No description provided for @settingsAppLockDescription.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서 생체 인증으로 앱을 보호합니다.'**
  String get settingsAppLockDescription;

  /// No description provided for @appLockEnableReason.
  ///
  /// In ko, this message translates to:
  /// **'앱 잠금을 켜려면 인증해주세요.'**
  String get appLockEnableReason;

  /// No description provided for @appLockDisableReason.
  ///
  /// In ko, this message translates to:
  /// **'앱 잠금을 끄려면 인증해주세요.'**
  String get appLockDisableReason;

  /// No description provided for @ocrTitle.
  ///
  /// In ko, this message translates to:
  /// **'사진에서 글자 추출'**
  String get ocrTitle;

  /// No description provided for @ocrSelectImage.
  ///
  /// In ko, this message translates to:
  /// **'사진 선택'**
  String get ocrSelectImage;

  /// No description provided for @ocrSelectImageHint.
  ///
  /// In ko, this message translates to:
  /// **'사진을 선택하면 아래에 인식한 텍스트가 표시됩니다.'**
  String get ocrSelectImageHint;

  /// No description provided for @ocrSelecting.
  ///
  /// In ko, this message translates to:
  /// **'사진을 선택하고 있어요.'**
  String get ocrSelecting;

  /// No description provided for @ocrRecognizing.
  ///
  /// In ko, this message translates to:
  /// **'텍스트를 인식하고 있어요.'**
  String get ocrRecognizing;

  /// No description provided for @ocrResultTitle.
  ///
  /// In ko, this message translates to:
  /// **'인식한 텍스트'**
  String get ocrResultTitle;

  /// No description provided for @ocrEmptyResult.
  ///
  /// In ko, this message translates to:
  /// **'인식된 텍스트가 없습니다. 글자가 선명한 사진을 선택해 주세요.'**
  String get ocrEmptyResult;

  /// No description provided for @ocrUnsupportedPlatform.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서는 텍스트 인식을 지원하지 않습니다.'**
  String get ocrUnsupportedPlatform;

  /// No description provided for @ocrPermissionDenied.
  ///
  /// In ko, this message translates to:
  /// **'사진 접근 권한을 확인해 주세요.'**
  String get ocrPermissionDenied;

  /// No description provided for @ocrImageSelectionFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진을 선택하지 못했습니다. 다시 시도해 주세요.'**
  String get ocrImageSelectionFailed;

  /// No description provided for @ocrInvalidImage.
  ///
  /// In ko, this message translates to:
  /// **'사용할 수 없는 이미지입니다. 다른 사진을 선택해 주세요.'**
  String get ocrInvalidImage;

  /// No description provided for @ocrRecognitionFailed.
  ///
  /// In ko, this message translates to:
  /// **'텍스트를 인식하지 못했습니다. 다시 시도해 주세요.'**
  String get ocrRecognitionFailed;

  /// No description provided for @ocrPreviewFailed.
  ///
  /// In ko, this message translates to:
  /// **'사진 미리보기를 표시하지 못했습니다.'**
  String get ocrPreviewFailed;

  /// No description provided for @settingsActivity.
  ///
  /// In ko, this message translates to:
  /// **'내 활동'**
  String get settingsActivity;

  /// No description provided for @settingsTools.
  ///
  /// In ko, this message translates to:
  /// **'도구'**
  String get settingsTools;

  /// No description provided for @settingsAdmin.
  ///
  /// In ko, this message translates to:
  /// **'관리자'**
  String get settingsAdmin;

  /// No description provided for @settingsChat.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get settingsChat;

  /// No description provided for @settingsBluetooth.
  ///
  /// In ko, this message translates to:
  /// **'Bluetooth 기기'**
  String get settingsBluetooth;

  /// No description provided for @settingsAdminWebView.
  ///
  /// In ko, this message translates to:
  /// **'관리자 웹뷰'**
  String get settingsAdminWebView;

  /// No description provided for @settingsServerStatus.
  ///
  /// In ko, this message translates to:
  /// **'서버 상태'**
  String get settingsServerStatus;

  /// No description provided for @settingsComingSoon.
  ///
  /// In ko, this message translates to:
  /// **'준비 중'**
  String get settingsComingSoon;

  /// No description provided for @settingsLight.
  ///
  /// In ko, this message translates to:
  /// **'라이트'**
  String get settingsLight;

  /// No description provided for @settingsDark.
  ///
  /// In ko, this message translates to:
  /// **'다크'**
  String get settingsDark;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In ko, this message translates to:
  /// **'설정을 저장하지 못했습니다. 다시 시도해 주세요.'**
  String get settingsSaveFailed;

  /// No description provided for @settingsProcessing.
  ///
  /// In ko, this message translates to:
  /// **'처리 중…'**
  String get settingsProcessing;

  /// No description provided for @settingsProfileUpdateFailed.
  ///
  /// In ko, this message translates to:
  /// **'프로필 사진을 변경하지 못했습니다. 권한과 연결 상태를 확인해 주세요.'**
  String get settingsProfileUpdateFailed;

  /// No description provided for @settingsLogoutFailed.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃을 완료하지 못했습니다. 다시 시도해 주세요.'**
  String get settingsLogoutFailed;

  /// No description provided for @settingsLogoutDeviceWarning.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃되었습니다. 알림 연결 해제는 확인하지 못했습니다.'**
  String get settingsLogoutDeviceWarning;

  /// No description provided for @settingsPointCount.
  ///
  /// In ko, this message translates to:
  /// **'{count} 포인트'**
  String settingsPointCount(int count);

  /// No description provided for @couponEventsTitle.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 이벤트'**
  String get couponEventsTitle;

  /// No description provided for @couponEventsEmpty.
  ///
  /// In ko, this message translates to:
  /// **'등록된 쿠폰 이벤트가 없습니다.'**
  String get couponEventsEmpty;

  /// No description provided for @couponLoginRequired.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 이벤트는 로그인 후 이용할 수 있어요.'**
  String get couponLoginRequired;

  /// No description provided for @couponLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 정보를 불러오지 못했습니다.'**
  String get couponLoadFailed;

  /// No description provided for @couponNetworkError.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인하고 다시 시도해주세요.'**
  String get couponNetworkError;

  /// No description provided for @couponRetry.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get couponRetry;

  /// No description provided for @couponRefresh.
  ///
  /// In ko, this message translates to:
  /// **'새로고침'**
  String get couponRefresh;

  /// No description provided for @couponLoadMore.
  ///
  /// In ko, this message translates to:
  /// **'더 보기'**
  String get couponLoadMore;

  /// No description provided for @couponRemainingCount.
  ///
  /// In ko, this message translates to:
  /// **'조회 당시 {count}장 남음'**
  String couponRemainingCount(int count);

  /// No description provided for @couponEventDetailTitle.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 이벤트 상세'**
  String get couponEventDetailTitle;

  /// No description provided for @couponIssuePeriod.
  ///
  /// In ko, this message translates to:
  /// **'발급 기간'**
  String get couponIssuePeriod;

  /// No description provided for @couponExpiresAt.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 만료 일시'**
  String get couponExpiresAt;

  /// No description provided for @couponIssuedAt.
  ///
  /// In ko, this message translates to:
  /// **'발급 일시'**
  String get couponIssuedAt;

  /// No description provided for @couponIssueButton.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰 받기'**
  String get couponIssueButton;

  /// No description provided for @couponIssuing.
  ///
  /// In ko, this message translates to:
  /// **'발급 결과 확인 중…'**
  String get couponIssuing;

  /// No description provided for @couponIssued.
  ///
  /// In ko, this message translates to:
  /// **'발급된 쿠폰이 있습니다.'**
  String get couponIssued;

  /// No description provided for @couponExpired.
  ///
  /// In ko, this message translates to:
  /// **'발급받은 쿠폰이 만료되었습니다.'**
  String get couponExpired;

  /// No description provided for @couponIssueFailed.
  ///
  /// In ko, this message translates to:
  /// **'발급 요청을 완료하지 못했습니다. 이벤트 정보를 새로고침해 주세요.'**
  String get couponIssueFailed;

  /// No description provided for @couponIssueUnconfirmed.
  ///
  /// In ko, this message translates to:
  /// **'발급 여부를 아직 확인하지 못했습니다. 실패로 확정된 것은 아닙니다. 발급 결과를 다시 확인해 주세요.'**
  String get couponIssueUnconfirmed;

  /// No description provided for @couponConfirmIssue.
  ///
  /// In ko, this message translates to:
  /// **'발급 결과 다시 확인'**
  String get couponConfirmIssue;

  /// No description provided for @couponRetryIssue.
  ///
  /// In ko, this message translates to:
  /// **'발급 요청 다시 보내기'**
  String get couponRetryIssue;

  /// No description provided for @couponRetryIssueHint.
  ///
  /// In ko, this message translates to:
  /// **'같은 계정으로 이미 발급받았다면 기존 쿠폰을 반환합니다.'**
  String get couponRetryIssueHint;

  /// No description provided for @couponEventDisabled.
  ///
  /// In ko, this message translates to:
  /// **'현재 신규 발급이 중지된 이벤트입니다.'**
  String get couponEventDisabled;

  /// No description provided for @couponEventNotStarted.
  ///
  /// In ko, this message translates to:
  /// **'아직 발급 시작 전입니다.'**
  String get couponEventNotStarted;

  /// No description provided for @couponEventEnded.
  ///
  /// In ko, this message translates to:
  /// **'발급 기간이 종료되었습니다.'**
  String get couponEventEnded;

  /// No description provided for @couponSoldOut.
  ///
  /// In ko, this message translates to:
  /// **'쿠폰이 모두 발급되었습니다.'**
  String get couponSoldOut;

  /// No description provided for @couponEventNotFound.
  ///
  /// In ko, this message translates to:
  /// **'이벤트를 찾을 수 없습니다.'**
  String get couponEventNotFound;

  /// No description provided for @couponRateLimited.
  ///
  /// In ko, this message translates to:
  /// **'요청이 많습니다. 잠시 후 다시 시도해 주세요.'**
  String get couponRateLimited;

  /// No description provided for @couponIssueNotice.
  ///
  /// In ko, this message translates to:
  /// **'잔여 수량은 조회 시점 기준이며, 최종 발급 가능 여부는 서버에서 확인합니다.'**
  String get couponIssueNotice;

  /// No description provided for @couponStorageOnlyNotice.
  ///
  /// In ko, this message translates to:
  /// **'현재는 발급·보관·만료 확인만 지원하며, 쿠폰 사용이나 포인트 교환은 지원하지 않습니다.'**
  String get couponStorageOnlyNotice;
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
