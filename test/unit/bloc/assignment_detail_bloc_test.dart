import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/training/presentation/bloc/assignment_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockTrainingRepository trainingRepo;
  late MockBduiDataProvider bduiProvider;

  setUp(() {
    trainingRepo = MockTrainingRepository();
    bduiProvider = MockBduiDataProvider();
  });

  AssignmentDetailBloc buildBloc({bool withBdui = false}) =>
      AssignmentDetailBloc(
        repository: trainingRepo,
        bduiDataProvider: withBdui ? bduiProvider : null,
      );

  group('AssignmentDetailBloc', () {
    test('initial state is AssignmentDetailInitial', () {
      expect(buildBloc().state, isA<AssignmentDetailInitial>());
    });

    blocTest<AssignmentDetailBloc, AssignmentDetailState>(
      'emits [Loading, Loaded] without BDUI provider',
      build: () {
        when(() => trainingRepo.getAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async => makeAssignmentDetail(id: 'a1'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignmentDetailLoadRequested('a1')),
      expect: () => [
        isA<AssignmentDetailLoading>(),
        isA<AssignmentDetailLoaded>()
            .having((s) => s.assignment.id, 'id', 'a1'),
      ],
    );

    blocTest<AssignmentDetailBloc, AssignmentDetailState>(
      'emits [Loading, LoadedWithBdui] when BDUI schema is available',
      build: () {
        when(() => trainingRepo.getAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async => makeAssignmentDetail(id: 'a1'));
        when(() => bduiProvider.getSchema('training-detail/a1'))
            .thenAnswer((_) async => null);
        return buildBloc(withBdui: true);
      },
      act: (bloc) => bloc.add(const AssignmentDetailLoadRequested('a1')),
      expect: () => [
        isA<AssignmentDetailLoading>(),
        isA<AssignmentDetailLoaded>(),
      ],
    );

    blocTest<AssignmentDetailBloc, AssignmentDetailState>(
      'falls back to Loaded when BDUI getSchema returns null',
      build: () {
        when(() => trainingRepo.getAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async => makeAssignmentDetail(id: 'a1'));
        when(() => bduiProvider.getSchema(any()))
            .thenAnswer((_) async => null);
        return buildBloc(withBdui: true);
      },
      act: (bloc) => bloc.add(const AssignmentDetailLoadRequested('a1')),
      expect: () => [
        isA<AssignmentDetailLoading>(),
        isA<AssignmentDetailLoaded>(),
      ],
    );

    blocTest<AssignmentDetailBloc, AssignmentDetailState>(
      'falls back to Loaded when BDUI getSchema throws',
      build: () {
        when(() => trainingRepo.getAssignment(assignmentId: 'a1'))
            .thenAnswer((_) async => makeAssignmentDetail(id: 'a1'));
        when(() => bduiProvider.getSchema(any()))
            .thenThrow(Exception('BDUI unavailable'));
        return buildBloc(withBdui: true);
      },
      act: (bloc) => bloc.add(const AssignmentDetailLoadRequested('a1')),
      expect: () => [
        isA<AssignmentDetailLoading>(),
        isA<AssignmentDetailLoaded>(),
      ],
    );

    blocTest<AssignmentDetailBloc, AssignmentDetailState>(
      'emits [Loading, Error] when training repository throws',
      build: () {
        when(() => trainingRepo.getAssignment(assignmentId: 'a1'))
            .thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const AssignmentDetailLoadRequested('a1')),
      expect: () => [
        isA<AssignmentDetailLoading>(),
        isA<AssignmentDetailError>(),
      ],
    );
  });
}
