import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class FcmTokenDataSource {
  FcmTokenDataSource({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> requestPermission()  {
    return _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> getToken() {
    return _messaging.getToken();
  }

  Stream<String> get onTokenRefresh {
    return _messaging.onTokenRefresh;
  }

  String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';

    throw UnsupportedError('지원하지 않는 플랫폼입니다.');
  }
}
