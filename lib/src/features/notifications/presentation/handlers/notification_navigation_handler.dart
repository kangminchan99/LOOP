import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_router/go_router.dart';
import 'package:loop/src/core/router/navigator_key.dart';
import 'package:loop/src/core/router/router_path.dart';

class NotificationNavigationHandler {
  const NotificationNavigationHandler._();

  // foreground 상태에서 FCM을 받았을 때 직접 로컬 알림을 띄우기 위한 플러그인.
  // background/terminated 상태의 FCM 시스템 알림 클릭은 firebase_messaging이 처리한다.
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // 앱 시작 시 한 번만 호출한다.
  // - foreground FCM 수신 → 로컬 알림 표시
  // - background 알림 클릭 → 게시글 상세 이동
  // - terminated 상태에서 알림 클릭으로 앱 실행 → 게시글 상세 이동
  static Future<void> initialize() async {
    await _initializeLocalNotifications();

    // 앱이 켜져 있는 상태에서는 FCM notification이 자동으로 표시되지 않을 수 있으므로
    // local notification으로 직접 보여준다.
    FirebaseMessaging.onMessage.listen(_showForegroundNotification);

    // 앱이 background 상태일 때 사용자가 푸시 알림을 누르면 호출된다.
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);

    // 앱이 완전히 종료된 상태에서 푸시 알림 클릭으로 실행된 경우의 최초 메시지.
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleRemoteMessage(initialMessage);
      });
    }
  }

  // flutter_local_notifications 초기화.
  // foreground에서 직접 띄운 로컬 알림을 눌렀을 때 payload를 읽어 라우팅한다.
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings();

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;

        final data = jsonDecode(payload) as Map<String, dynamic>;
        _handleData(data);
      },
    );
  }

  // foreground 상태에서 FCM을 받으면 local notification으로 직접 표시한다.
  // 서버가 보낸 message.data는 payload로 넣어두고, 사용자가 알림을 누르면 다시 꺼내 쓴다.
  static Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;

    final title = notification?.title ?? '알림';
    final body = notification?.body ?? '';

    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      '기본 알림',
      channelDescription: '일반 알림 채널',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: title,
      body: body,
      notificationDetails: details,
      payload: jsonEncode(message.data),
    );
  }

  // background/terminated FCM 클릭 이벤트를 공통 data 처리 함수로 위임한다.
  static void _handleRemoteMessage(RemoteMessage message) {
    _handleData(message.data);
  }

  // 서버 FCM data payload를 해석해 화면 이동을 처리한다.
  // 현재는 새 게시글 알림(new_post)만 게시글 상세로 이동시킨다.
  static void _handleData(Map<String, dynamic> data) {
    final type = data['type'];
    final postId = data['postId'];

    if (type != 'new_post') return;
    if (postId == null || postId.toString().isEmpty) return;

    final context = navigatorKey.currentContext;
    if (context == null) return;

    context.pushNamed(
      AppRoute.postDetail.name,
      pathParameters: {'postId': postId.toString()},
    );
  }
}
