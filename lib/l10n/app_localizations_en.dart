// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Loop';

  @override
  String get loginStartTitle => 'Get started';

  @override
  String get loginStartDescription =>
      'Connect easily with people who think like you.';

  @override
  String get loginIdOrEmailHint => 'Username or email';

  @override
  String get loginPasswordHint => 'Password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loginWithKakao => 'Continue with Kakao';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get signUpQuestion => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get appShellHome => 'Home';

  @override
  String get appShellMyPage => 'My Page';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsCommunity => 'Community';

  @override
  String get settingsAppSettings => 'App settings';

  @override
  String get settingsSupport => 'Support';

  @override
  String get settingsMyComments => 'My comments';

  @override
  String get settingsAttendanceCheck => 'Attendance check';

  @override
  String get settingsNotificationList => 'Notifications';

  @override
  String get settingsBlockedUsers => 'Blocked users';

  @override
  String get settingsSavedPosts => 'Saved posts';

  @override
  String get settingsNotificationSettings => 'Notifications';

  @override
  String get settingsDisplayMode => 'Display mode';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsNotice => 'Notice';

  @override
  String get settingsContact => 'Contact us';

  @override
  String get settingsTermsPrivacy => 'Terms & Privacy Policy';

  @override
  String get settingsOn => 'On';

  @override
  String get settingsSystem => 'System';

  @override
  String get settingsKorean => '한국어';

  @override
  String get settingsEnglish => 'English';

  @override
  String get settingsLoginRequiredTitle => 'Log in required';

  @override
  String get settingsLoginRequiredDescription =>
      'You can create posts, manage saved posts,\nand view your comments after logging in.';

  @override
  String get settingsLoginSignup => 'Log in / Sign up';

  @override
  String get settingsLogout => 'Log out';

  @override
  String get settingsLogoutComplete => 'You have been logged out.';

  @override
  String get settingsUploadFailed => 'Upload failed';

  @override
  String get settingsNoProfileImage => 'None';

  @override
  String get settingsNoEmail => 'No email';

  @override
  String get settingsPoints => 'points';

  @override
  String get settingsEdit => 'Edit';

  @override
  String get languageDialogTitle => 'Language';

  @override
  String get languageDialogClose => 'Close';

  @override
  String get postsConnectionUnavailable =>
      'Cannot reach the server. Only previously loaded posts are available.';

  @override
  String get postsRefreshFailed => 'Could not refresh posts. Please try again.';

  @override
  String get postsShowingCache => 'Showing posts saved on this device.';

  @override
  String get postsRetry => 'Retry';

  @override
  String get postsRefresh => 'Refresh';

  @override
  String get appLockTitle => 'App locked';

  @override
  String get appLockDescription => 'Authenticate to access the app.';

  @override
  String get appLockChecking => 'Checking authentication status…';

  @override
  String get appLockUnlock => 'Unlock';

  @override
  String get appLockRetry => 'Retry';

  @override
  String get appLockError =>
      'Could not verify authentication or lock settings. Please try again.';

  @override
  String get appLockReason => 'Authenticate to unlock the app.';

  @override
  String get settingsAppLock => 'Biometric app lock';

  @override
  String get settingsAppLockDescription =>
      'Protect the app with biometric authentication on this device.';

  @override
  String get appLockEnableReason => 'Authenticate to enable app lock.';

  @override
  String get appLockDisableReason => 'Authenticate to disable app lock.';

  @override
  String get ocrTitle => 'Extract text from a photo';

  @override
  String get ocrSelectImage => 'Select photo';

  @override
  String get ocrSelectImageHint =>
      'Select a photo to display the recognized text below.';

  @override
  String get ocrSelecting => 'Selecting a photo.';

  @override
  String get ocrRecognizing => 'Recognizing text.';

  @override
  String get ocrResultTitle => 'Recognized text';

  @override
  String get ocrEmptyResult =>
      'No text was found. Select a photo with clear text.';

  @override
  String get ocrUnsupportedPlatform =>
      'Text recognition is not supported on this device.';

  @override
  String get ocrPermissionDenied =>
      'Please check your photo access permission.';

  @override
  String get ocrImageSelectionFailed =>
      'Could not select a photo. Please try again.';

  @override
  String get ocrInvalidImage =>
      'This image cannot be used. Please select another photo.';

  @override
  String get ocrRecognitionFailed =>
      'Could not recognize the text. Please try again.';

  @override
  String get ocrPreviewFailed => 'Could not display the photo preview.';

  @override
  String get settingsActivity => 'My activity';

  @override
  String get settingsTools => 'Tools';

  @override
  String get settingsAdmin => 'Administration';

  @override
  String get settingsChat => 'Chat';

  @override
  String get settingsBluetooth => 'Bluetooth devices';

  @override
  String get settingsAdminWebView => 'Admin web view';

  @override
  String get settingsServerStatus => 'Server status';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get settingsLight => 'Light';

  @override
  String get settingsDark => 'Dark';

  @override
  String get settingsSaveFailed =>
      'Could not save your settings. Please try again.';

  @override
  String get settingsProcessing => 'Processing…';

  @override
  String get settingsProfileUpdateFailed =>
      'Could not update your photo. Check permissions and your connection.';

  @override
  String get settingsLogoutFailed =>
      'Could not complete logout. Please try again.';

  @override
  String get settingsLogoutDeviceWarning =>
      'Logged out. Notification unlinking could not be confirmed.';

  @override
  String settingsPointCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString points';
  }

  @override
  String get couponEventsTitle => 'Coupon events';

  @override
  String get couponEventsEmpty => 'No coupon events are available.';

  @override
  String get couponLoginRequired => 'Please sign in to view coupon events.';

  @override
  String get couponLoadFailed => 'Could not load coupon information.';

  @override
  String get couponNetworkError => 'Check your connection and try again.';

  @override
  String get couponRetry => 'Try again';

  @override
  String get couponRefresh => 'Refresh';

  @override
  String get couponLoadMore => 'Load more';

  @override
  String couponRemainingCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString remaining when checked';
  }
}
