import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/auth_manager.dart';
import '../auth/auth_state.dart';
import 'api_providers.dart';

final secureStorageProvider = Provider<FlutterSecureStorage>((_) {
  return const FlutterSecureStorage();
});

final authManagerProvider = Provider<AuthManager>((ref) {
  final manager = AuthManager(
    secureStorage: ref.watch(secureStorageProvider),
    dio: ref.watch(rawDioProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  final manager = ref.watch(authManagerProvider);
  return manager.authStateStream;
});
