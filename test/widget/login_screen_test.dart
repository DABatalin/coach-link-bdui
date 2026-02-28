import 'package:coach_link/core/di/auth_providers.dart';
import 'package:coach_link/core/di/repository_providers.dart';
import 'package:coach_link/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/mock_repositories.dart';
import '../helpers/pump_app.dart';

void main() {
  late MockAuthRepository authRepo;
  late MockAuthManager authManager;

  setUpAll(() async {
    await setupLocalization();
  });

  setUp(() {
    authRepo = MockAuthRepository();
    authManager = MockAuthManager();
  });

  Future<void> buildApp(WidgetTester tester) =>
      tester.pumpLocalizedApp(
        const LoginScreen(),
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepo),
          authManagerProvider.overrideWithValue(authManager),
        ],
      );

  group('LoginScreen', () {
    testWidgets('renders login form with all fields', (tester) async {
      await buildApp(tester);

      expect(find.text('CoachLink'), findsOneWidget);
      expect(find.text('Войдите в аккаунт'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Логин'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Пароль'), findsOneWidget);
      expect(find.text('Войти'), findsOneWidget);
    });

    testWidgets('shows validation error when login is empty on submit',
        (tester) async {
      await buildApp(tester);

      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите логин'), findsOneWidget);
    });

    testWidgets('shows validation error when password is empty on submit',
        (tester) async {
      await buildApp(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Логин'), 'mylogin');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('shows both validation errors when all fields are empty',
        (tester) async {
      await buildApp(tester);

      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите логин'), findsOneWidget);
      expect(find.text('Введите пароль'), findsOneWidget);
    });

    testWidgets('no validation errors with filled fields', (tester) async {
      when(() => authRepo.login(
            login: any(named: 'login'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => throw Exception('skip'));

      await buildApp(tester);

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Логин'), 'coach1');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Пароль'), 'pass123');
      await tester.tap(find.text('Войти'));
      await tester.pump();

      expect(find.text('Введите логин'), findsNothing);
      expect(find.text('Введите пароль'), findsNothing);
    });

    testWidgets('shows register navigation link', (tester) async {
      await buildApp(tester);

      expect(find.text('Нет аккаунта? Зарегистрироваться'), findsOneWidget);
    });
  });
}
