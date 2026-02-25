import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/widgets.dart';

class AnalyticsService {
  bool get _isAvailable => Firebase.apps.isNotEmpty;

  NavigatorObserver get observer {
    if (!_isAvailable) return NavigatorObserver();
    return FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);
  }

  Future<void> setUser(String userId) async {
    if (!_isAvailable) return;
    await Future.wait([
      FirebaseAnalytics.instance.setUserId(id: userId),
      FirebaseCrashlytics.instance.setUserIdentifier(userId),
    ]);
  }

  Future<void> clearUser() async {
    if (!_isAvailable) return;
    await Future.wait([
      FirebaseAnalytics.instance.setUserId(id: null),
      FirebaseCrashlytics.instance.setUserIdentifier(''),
    ]);
  }

  Future<void> logLogin() async {
    if (!_isAvailable) return;
    await FirebaseAnalytics.instance.logLogin(loginMethod: 'email');
  }

  Future<void> logSignUp({required String role}) async {
    if (!_isAvailable) return;
    await FirebaseAnalytics.instance.logSignUp(signUpMethod: role);
  }

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) async {
    if (!_isAvailable) return;
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> recordError(Object exception, StackTrace? stack) async {
    if (!_isAvailable) return;
    await FirebaseCrashlytics.instance.recordError(exception, stack);
  }

  Future<void> recordFatalError(Object exception, StackTrace? stack) async {
    if (!_isAvailable) return;
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      fatal: true,
    );
  }
}
