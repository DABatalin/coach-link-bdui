import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/auth_state.dart';
import 'core/di/auth_providers.dart';
import 'core/di/repository_providers.dart';
import 'core/navigation/app_router.dart';
import 'core/notifications/fcm_service.dart';
import 'core/theme/app_theme.dart';

class CoachLinkApp extends ConsumerStatefulWidget {
  const CoachLinkApp({super.key});

  @override
  ConsumerState<CoachLinkApp> createState() => _CoachLinkAppState();
}

class _CoachLinkAppState extends ConsumerState<CoachLinkApp> {
  @override
  void initState() {
    super.initState();
    ref.read(authManagerProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    // Watch auth state — when user logs in, initialize FCM and register token
    ref.listen<AsyncValue<AuthState>>(authStateProvider, (_, next) {
      final auth = next.valueOrNull;
      if (auth is Authenticated) {
        _setupFcm(router);
      }
    });

    return MaterialApp.router(
      title: 'CoachLink',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }

  Future<void> _setupFcm(dynamic router) async {
    // Only run if Firebase was successfully initialized
    if (!Firebase.apps.isNotEmpty) return;

    try {
      await FCMService.initialize(router: router);
      await FCMService.requestPermissionAndRegisterToken(
        repository: ref.read(notificationsRepositoryProvider),
      );
    } catch (e) {
      debugPrint('[FCM] Setup error: $e');
    }
  }
}
