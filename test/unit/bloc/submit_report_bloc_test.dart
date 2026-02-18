import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/core/api/api_exceptions.dart';
import 'package:coach_link/features/reports/presentation/bloc/submit_report_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockReportsRepository reportsRepo;

  setUp(() {
    reportsRepo = MockReportsRepository();
  });

  SubmitReportBloc buildBloc() => SubmitReportBloc(repository: reportsRepo);

  const validEvent = ReportSubmitted(
    assignmentId: 'a1',
    content: 'Great session',
    durationMinutes: 60,
    perceivedEffort: 7,
  );

  group('SubmitReportBloc', () {
    test('initial state is SubmitReportInitial', () {
      expect(buildBloc().state, isA<SubmitReportInitial>());
    });

    blocTest<SubmitReportBloc, SubmitReportState>(
      'emits [Loading, Success] on successful report submission',
      build: () {
        when(() => reportsRepo.submitReport(
              assignmentId: any(named: 'assignmentId'),
              content: any(named: 'content'),
              durationMinutes: any(named: 'durationMinutes'),
              perceivedEffort: any(named: 'perceivedEffort'),
              maxHeartRate: any(named: 'maxHeartRate'),
              avgHeartRate: any(named: 'avgHeartRate'),
              distanceKm: any(named: 'distanceKm'),
            )).thenAnswer((_) async => makeReport());
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [isA<SubmitReportLoading>(), isA<SubmitReportSuccess>()],
    );

    blocTest<SubmitReportBloc, SubmitReportState>(
      'emits [Loading, Failure] on DioException',
      build: () {
        when(() => reportsRepo.submitReport(
              assignmentId: any(named: 'assignmentId'),
              content: any(named: 'content'),
              durationMinutes: any(named: 'durationMinutes'),
              perceivedEffort: any(named: 'perceivedEffort'),
              maxHeartRate: any(named: 'maxHeartRate'),
              avgHeartRate: any(named: 'avgHeartRate'),
              distanceKm: any(named: 'distanceKm'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: ''),
          error: const ConflictException(
            message: 'Отчёт уже отправлен',
            code: 'REPORT_EXISTS',
          ),
        ));
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [
        isA<SubmitReportLoading>(),
        isA<SubmitReportFailure>().having(
          (s) => s.message,
          'message',
          'Отчёт уже отправлен',
        ),
      ],
    );

    blocTest<SubmitReportBloc, SubmitReportState>(
      'emits [Loading, Failure] on unknown error',
      build: () {
        when(() => reportsRepo.submitReport(
              assignmentId: any(named: 'assignmentId'),
              content: any(named: 'content'),
              durationMinutes: any(named: 'durationMinutes'),
              perceivedEffort: any(named: 'perceivedEffort'),
              maxHeartRate: any(named: 'maxHeartRate'),
              avgHeartRate: any(named: 'avgHeartRate'),
              distanceKm: any(named: 'distanceKm'),
            )).thenThrow(Exception('Timeout'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(validEvent),
      expect: () => [isA<SubmitReportLoading>(), isA<SubmitReportFailure>()],
    );
  });
}
