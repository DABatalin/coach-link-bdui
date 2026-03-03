import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/reports/presentation/bloc/view_report_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockReportsRepository reportsRepo;

  setUp(() {
    reportsRepo = MockReportsRepository();
  });

  ViewReportBloc buildBloc() => ViewReportBloc(repository: reportsRepo);

  group('ViewReportBloc', () {
    test('initial state is ViewReportInitial', () {
      expect(buildBloc().state, isA<ViewReportInitial>());
    });

    blocTest<ViewReportBloc, ViewReportState>(
      'emits [Loading, Loaded] with report on success',
      build: () {
        when(() => reportsRepo.getReport(assignmentId: 'a1'))
            .thenAnswer((_) async => makeReport());
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ViewReportLoadRequested('a1')),
      expect: () => [
        isA<ViewReportLoading>(),
        isA<ViewReportLoaded>()
            .having((s) => s.report.assignmentId, 'assignmentId', 'a1'),
      ],
      verify: (_) =>
          verify(() => reportsRepo.getReport(assignmentId: 'a1')).called(1),
    );

    blocTest<ViewReportBloc, ViewReportState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => reportsRepo.getReport(assignmentId: 'a1'))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ViewReportLoadRequested('a1')),
      expect: () => [isA<ViewReportLoading>(), isA<ViewReportError>()],
    );
  });
}
