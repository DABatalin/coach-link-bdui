import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/di/auth_providers.dart';
import 'core/navigation/app_router.dart';
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
    // Initialize auth manager — reads stored tokens and emits auth state
    ref.read(authManagerProvider).init();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CoachLink',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
