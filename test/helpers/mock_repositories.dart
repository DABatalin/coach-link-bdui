import 'package:coach_link/core/analytics/analytics_service.dart';
import 'package:coach_link/core/auth/auth_manager.dart';
import 'package:coach_link/core/bdui/bdui_action_handler.dart';
import 'package:coach_link/core/bdui/bdui_data_provider.dart';
import 'package:coach_link/features/auth/domain/auth_repository.dart';
import 'package:coach_link/features/connections/domain/connections_repository.dart';
import 'package:coach_link/features/groups/domain/groups_repository.dart';
import 'package:coach_link/features/notifications/domain/notifications_repository.dart';
import 'package:coach_link/features/profile/domain/profile_repository.dart';
import 'package:coach_link/features/reports/domain/reports_repository.dart';
import 'package:coach_link/features/training/domain/training_repository.dart';
import 'package:flutter/widgets.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockProfileRepository extends Mock implements ProfileRepository {}

class MockTrainingRepository extends Mock implements TrainingRepository {}

class MockConnectionsRepository extends Mock implements ConnectionsRepository {}

class MockGroupsRepository extends Mock implements GroupsRepository {}

class MockReportsRepository extends Mock implements ReportsRepository {}

class MockNotificationsRepository extends Mock implements NotificationsRepository {}

class MockAuthManager extends Mock implements AuthManager {}

class MockBduiDataProvider extends Mock implements BduiDataProvider {}

class MockBduiActionHandler extends Mock implements BduiActionHandler {}

class MockAnalyticsService extends Fake implements AnalyticsService {
  @override
  NavigatorObserver get observer => NavigatorObserver();

  @override
  Future<void> setUser(String userId) async {}

  @override
  Future<void> clearUser() async {}

  @override
  Future<void> logLogin() async {}

  @override
  Future<void> logSignUp({required String role}) async {}

  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> recordError(Object exception, StackTrace? stack) async {}

  @override
  Future<void> recordFatalError(Object exception, StackTrace? stack) async {}
}
