import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/training/presentation/bloc/assignments_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockTrainingRepository trainingRepo;

  setUp(() {
    trainingRepo = MockTrainingRepository();
  });

  AssignmentsBloc buildBloc() =>
      AssignmentsBloc(repository: trainingRepo);

  group('AssignmentsBloc', () {
    test('initial state is AssignmentsInitial', () {
      expect(buildBloc().state, isA<AssignmentsInitial>());
    });

    blocTest<AssignmentsBloc, AssignmentsState>(
      'emits [Loading, Loaded] with items on load',
      build: () {
        when(() => trainingRepo.getAssignments()).thenAnswer(
          (_) async => makePaginated([
            makeAssignment(id: 'a1'),
            makeAssignment(id: 'a2'),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignmentsLoadRequested()),
      expect: () => [
        isA<AssignmentsLoading>(),
        isA<AssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 2),
      ],
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'emits [Loading, Loaded(empty)] when no assignments',
      build: () {
        when(() => trainingRepo.getAssignments())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignmentsLoadRequested()),
      expect: () => [
        isA<AssignmentsLoading>(),
        isA<AssignmentsLoaded>()
            .having((s) => s.assignments, 'assignments', isEmpty),
      ],
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => trainingRepo.getAssignments())
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignmentsLoadRequested()),
      expect: () => [
        isA<AssignmentsLoading>(),
        isA<AssignmentsError>(),
      ],
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'calls deleteAssignment and reloads list on AssignmentDeleteRequested',
      build: () {
        when(() => trainingRepo.deleteAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async {});
        when(() => trainingRepo.getAssignments())
            .thenAnswer((_) async => makePaginated([makeAssignment(id: 'a2')]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AssignmentDeleteRequested('a1')),
      expect: () => [
        isA<AssignmentsLoading>(),
        isA<AssignmentsLoaded>()
            .having((s) => s.assignments.length, 'length', 1),
      ],
      verify: (_) =>
          verify(() => trainingRepo.deleteAssignment(assignmentId: 'a1'))
              .called(1),
    );

    blocTest<AssignmentsBloc, AssignmentsState>(
      'calls archiveAssignment and reloads on AssignmentArchiveRequested',
      build: () {
        when(() => trainingRepo.archiveAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async {});
        when(() => trainingRepo.getAssignments())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const AssignmentArchiveRequested('a1')),
      verify: (_) =>
          verify(() => trainingRepo.archiveAssignment(assignmentId: 'a1'))
              .called(1),
    );
  });
}
