import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

const String kAccessTokenKey = 'auth_access_token';
const String kRefreshTokenKey = 'auth_refresh_token';

/// API 서버 기본 URL.
/// .env 파일의 API_URL 값을 우선 사용하며, 없을 경우 플랫폼별 기본값 자동 선택.
///
/// 플랫폼별 로컬 개발 설정 (.env):
///   Android 에뮬레이터: API_URL=http://10.0.2.2:3000
///   iOS 시뮬레이터:     API_URL=http://localhost:3000
///   실제 기기:          API_URL=http://<컴퓨터 IP>:3000
///   웹/데스크톱:         API_URL=http://localhost:3000
String get apiUrl => dotenv.env['API_URL'] ?? _defaultApiUrl;

/// .env에 API_URL이 없을 때 플랫폼에 따라 자동 선택.
/// - Android 에뮬레이터: 10.0.2.2 (호스트 PC의 localhost)
/// - 그 외 (iOS 시뮬레이터, 웹, 데스크톱): localhost
String get _defaultApiUrl {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    return 'http://10.0.2.2:3000';
  }
  return 'http://localhost:3000';
}
