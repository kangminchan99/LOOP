import 'package:loop/src/features/settings/domain/models/setting_model.dart';

class SettingConstants {
  // 로그인 상태 섹션
  static final List<SettingSection> loggedInSections = [
    SettingSection(
      title: '계정',
      items: [
        SettingItem(icon: '💬', label: '내 댓글'),
        SettingItem(icon: '🎯', label: '출석 체크'),
        SettingItem(icon: '🔔', label: '알림 목록'),
      ],
    ),
    SettingSection(
      title: '커뮤니티',
      items: [
        SettingItem(icon: '🛡️', label: '차단한 사용자'),
        SettingItem(icon: '📌', label: '저장한 글'),
        SettingItem(icon: '', label: ''),
      ],
    ),
    SettingSection(
      title: '앱 설정',
      items: [
        SettingItem(icon: '🔔', label: '알림 설정', value: '켜짐'),
        SettingItem(icon: '🌙', label: '화면 모드', value: '시스템'),
        SettingItem(icon: '🌐', label: '언어', value: '한국어'),
      ],
    ),
    SettingSection(
      title: '지원',
      items: [
        SettingItem(icon: '📢', label: '공지사항'),
        SettingItem(icon: '❓', label: '문의하기'),
        SettingItem(icon: '📄', label: '약관 및 개인정보 처리방침'),
      ],
    ),
  ];

  // 미로그인 상태 섹션
  static final List<SettingSection> notLoggedInSections = [
    SettingSection(
      title: '앱 설정',
      items: [
        SettingItem(icon: '🔔', label: '알림 설정', value: '켜짐'),
        SettingItem(icon: '🌙', label: '화면 모드', value: '시스템'),
        SettingItem(icon: '🌐', label: '언어', value: '한국어'),
      ],
    ),
    SettingSection(
      title: '지원',
      items: [
        SettingItem(icon: '📢', label: '공지사항'),
        SettingItem(icon: '❓', label: '문의하기'),
        SettingItem(icon: '📄', label: '약관 및 개인정보 처리방침'),
      ],
    ),
  ];

  static const String appVersion = 'loop v1.0.0';
}
