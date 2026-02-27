import 'package:coach_link/firebase_options.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/analytics/analytics_bloc_observer.dart';
import 'core/analytics/analytics_service.dart';
import 'core/notifications/fcm_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  
  await Hive.initFlutter();
  await Hive.openBox<String>('bdui_schemas');

  await _initFirebase();

  final analyticsService = AnalyticsService();
  Bloc.observer = AnalyticsBlocObserver(analyticsService);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('ru'), // Русский
        Locale('en'), // Английский
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ru'),
      startLocale: const Locale('ru'),
      saveLocale: true,
      useOnlyLangCode: true,
      child: const ProviderScope(child: CoachLinkApp()),
    ),
  );
}

Future<void> _initFirebase() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);

    debugPrint('[Firebase] initialized');
  } catch (e) {
    debugPrint('[Firebase] not configured — analytics and crash reporting '
        'disabled. Run `flutterfire configure` to enable them. Error: $e');
  }
}
