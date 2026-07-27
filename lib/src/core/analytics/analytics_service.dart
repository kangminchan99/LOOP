import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

class AnalyticsService {
  AnalyticsService(this._analytics);

  final FirebaseAnalytics _analytics;

  Future<void> logLogin({required String method}) {
    return _analytics.logLogin(loginMethod: method);
  }

  Future<void> logSignUp({required String method}) {
    return _analytics.logSignUp(signUpMethod: method);
  }

  Future<void> logPostCreate({required int postId}) {
    return _analytics.logEvent(
      name: 'post_create',
      parameters: {'post_id': postId},
    );
  }

  Future<void> logPostView({required int postId}) {
    return _analytics.logEvent(
      name: 'post_view',
      parameters: {'post_id': postId},
    );
  }

  Future<void> logCommentCreate({required int postId}) {
    debugPrint('[Analytics] comment_create postId=$postId');

    return _analytics.logEvent(
      name: 'comment_create',
      parameters: {'post_id': postId},
    );
  }

  Future<void> setUserId(int? userId) {
    return _analytics.setUserId(id: userId?.toString());
  }
}
