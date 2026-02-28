import 'package:coach_link/core/auth/auth_state.dart';
import 'package:coach_link/core/bdui/bdui_providers.dart';
import 'package:coach_link/core/di/auth_providers.dart';
import 'package:coach_link/core/di/repository_providers.dart';
import 'package:coach_link/features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import 'package:coach_link/shared/models/paginated_result.dart';
import 'package:coach_link/shared/models/pagination.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/pump_app.dart';
import '../helpers/test_data.dart';

void main() {
  late MockConnectionsRepository connectionsRepo;
  late MockTrainingRepository trainingRepo;
  late MockAuthManager authManager;
  late MockBduiDataProvider bduiProvider;
  late MockBduiActionHandler actionHandler;

  setUpAll(() async {
    await setupLocalization();
  });

  setUp(() {
    connectionsRepo = MockConnectionsRepository();
    trainingRepo = MockTrainingRepository();
    authManager = MockAuthManager();
    bduiProvider = MockBduiDataProvider();
    actionHandler = MockBduiActionHandler();

    when(() => authManager.currentState).thenReturn(
      const Authenticated(
        userId: 'u1',
        login: 'coach1',
        fullName: 'Coach One',
        role: 'coach',
      ),
    );

    // BDUI disabled
    when(() => bduiProvider.getSchema(any())).thenAnswer((_) async => null);
  });

  Future<void> buildApp(WidgetTester tester) =>
      tester.pumpLocalizedApp(
        const CoachDashboardScreen(),
        overrides: [
          connectionsRepositoryProvider.overrideWithValue(connectionsRepo),
          trainingRepositoryProvider.overrideWithValue(trainingRepo),
          authManagerProvider.overrideWithValue(authManager),
          bduiDataProviderProvider.overrideWithValue(bduiProvider),
          bduiActionHandlerProvider.overrideWithValue(actionHandler),
        ],
      );

  void stubRepos({int athleteCount = 0, int requestsCount = 0}) {
    when(() => connectionsRepo.getCoachAthletes(pageSize: 1)).thenAnswer(
      (_) async => PaginatedResult(
        items: [],
        pagination: Pagination(
          page: 1,
          pageSize: 1,
          totalItems: athleteCount,
          totalPages: athleteCount == 0 ? 0 : 1,
        ),
      ),
    );
    when(() => connectionsRepo.getIncomingRequests(pageSize: 1)).thenAnswer(
      (_) async => PaginatedResult(
        items: [],
        pagination: Pagination(
          page: 1,
          pageSize: 1,
          totalItems: requestsCount,
          totalPages: requestsCount == 0 ? 0 : 1,
        ),
      ),
    );
    when(() => trainingRepo.getAssignments(pageSize: 5))
        .thenAnswer((_) async => makePaginated([]));
  }

  group('CoachDashboardScreen', () {
    testWidgets('shows greeting with coach name after load', (tester) async {
      stubRepos();
      await buildApp(tester);

      expect(find.textContaining('Coach One'), findsOneWidget);
    });

    testWidgets('shows athlete count card', (tester) async {
      stubRepos(athleteCount: 3);
      await buildApp(tester);

      expect(find.text('Спортсмены'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('shows pending requests count', (tester) async {
      stubRepos(requestsCount: 2);
      await buildApp(tester);

      expect(find.text('Заявки'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('shows "Нет заданий" when assignments list is empty',
        (tester) async {
      stubRepos();
      await buildApp(tester);

      expect(find.text('Нет заданий'), findsOneWidget);
    });

    testWidgets('shows assignment title in list', (tester) async {
      stubRepos(athleteCount: 1);
      when(() => trainingRepo.getAssignments(pageSize: 5)).thenAnswer(
        (_) async => makePaginated([
          makeAssignment(id: 'a1', athleteFullName: 'Athlete One'),
        ]),
      );
      await buildApp(tester);

      expect(find.text('Test Assignment a1'), findsOneWidget);
    });
  });
}
