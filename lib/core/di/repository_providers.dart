import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/ai/data/ai_repository_impl.dart';
import '../../features/ai/data/ai_repository_mock.dart';
import '../../features/ai/domain/ai_repository.dart';
import '../../features/analytics/data/analytics_repository_impl.dart';
import '../../features/analytics/data/analytics_repository_mock.dart';
import '../../features/analytics/domain/analytics_repository.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/data/auth_repository_mock.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/connections/data/connections_repository_impl.dart';
import '../../features/connections/data/connections_repository_mock.dart';
import '../../features/connections/domain/connections_repository.dart';
import '../../features/groups/data/groups_repository_impl.dart';
import '../../features/groups/data/groups_repository_mock.dart';
import '../../features/groups/domain/groups_repository.dart';
import '../../features/notifications/data/notifications_repository_impl.dart';
import '../../features/notifications/data/notifications_repository_mock.dart';
import '../../features/notifications/domain/notifications_repository.dart';
import '../../features/profile/data/profile_repository_impl.dart';
import '../../features/profile/data/profile_repository_mock.dart';
import '../../features/profile/domain/profile_repository.dart';
import '../../features/reports/data/reports_repository_impl.dart';
import '../../features/reports/data/reports_repository_mock.dart';
import '../../features/reports/domain/reports_repository.dart';
import '../../features/training/data/training_repository_impl.dart';
import '../../features/training/data/training_repository_mock.dart';
import '../../features/training/domain/training_repository.dart';
import 'api_providers.dart';
import '../auth/auth_state.dart';
import 'auth_providers.dart';

/// Set to true to use mock repositories (no backend needed)
const useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: true);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (useMocks) return AuthRepositoryMock();
  return AuthRepositoryImpl(ref.watch(dioProvider));
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  if (useMocks) {
    final auth = ref.watch(authManagerProvider);
    final role = switch (auth.currentState) {
      Authenticated s => s.role,
      _ => 'athlete',
    };
    return ProfileRepositoryMock(role: role);
  }
  return ProfileRepositoryImpl(ref.watch(dioProvider));
});

final connectionsRepositoryProvider = Provider<ConnectionsRepository>((ref) {
  if (useMocks) return ConnectionsRepositoryMock();
  return ConnectionsRepositoryImpl(ref.watch(dioProvider));
});

final groupsRepositoryProvider = Provider<GroupsRepository>((ref) {
  if (useMocks) return GroupsRepositoryMock();
  return GroupsRepositoryImpl(ref.watch(dioProvider));
});

final trainingRepositoryProvider = Provider<TrainingRepository>((ref) {
  if (useMocks) return TrainingRepositoryMock();
  return TrainingRepositoryImpl(ref.watch(dioProvider));
});

final reportsRepositoryProvider = Provider<ReportsRepository>((ref) {
  if (useMocks) return ReportsRepositoryMock();
  return ReportsRepositoryImpl(ref.watch(dioProvider));
});

final notificationsRepositoryProvider =
    Provider<NotificationsRepository>((ref) {
  if (useMocks) return NotificationsRepositoryMock();
  return NotificationsRepositoryImpl(ref.watch(dioProvider));
});

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  if (useMocks) return AnalyticsRepositoryMock();
  return AnalyticsRepositoryImpl(ref.watch(dioProvider));
});

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  if (useMocks) return AiRepositoryMock();
  return AiRepositoryImpl(ref.watch(dioProvider));
});
