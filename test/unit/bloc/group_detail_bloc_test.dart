import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/groups/presentation/bloc/group_detail_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:coach_link/features/groups/domain/models/training_group.dart';
import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGroupsRepository groupsRepo;
  late MockTrainingRepository trainingRepo;

  setUp(() {
    groupsRepo = MockGroupsRepository();
    trainingRepo = MockTrainingRepository();
  });

  GroupDetailBloc buildBloc() => GroupDetailBloc(
        repository: groupsRepo,
        trainingRepository: trainingRepo,
      );

  group('GroupDetailBloc', () {
    test('initial state is GroupDetailInitial', () {
      expect(buildBloc().state, isA<GroupDetailInitial>());
    });

    blocTest<GroupDetailBloc, GroupDetailState>(
      'emits [Loading, Loaded] with group and assignments',
      build: () {
        when(() => groupsRepo.getGroup(groupId: 'g1'))
            .thenAnswer((_) async => makeGroupDetail(id: 'g1'));
        when(() => trainingRepo.getAssignments(groupId: 'g1', pageSize: 50))
            .thenAnswer((_) async =>
                makePaginated([makeAssignment(id: 'a1')]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupDetailLoadRequested('g1')),
      expect: () => [
        isA<GroupDetailLoading>(),
        isA<GroupDetailLoaded>()
            .having((s) => s.group.id, 'group.id', 'g1')
            .having((s) => s.assignments.length, 'assignments', 1),
      ],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'emits [Loading, Error] when group load fails',
      build: () {
        when(() => groupsRepo.getGroup(groupId: 'g1'))
            .thenThrow(Exception('Not found'));
        when(() => trainingRepo.getAssignments(groupId: 'g1', pageSize: 50))
            .thenThrow(Exception('Not found'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupDetailLoadRequested('g1')),
      expect: () => [isA<GroupDetailLoading>(), isA<GroupDetailError>()],
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'GroupMemberAdded calls addMember and reloads',
      build: () {
        when(() => groupsRepo.addMember(groupId: 'g1', athleteId: 'ath1'))
            .thenAnswer((_) async => GroupMember(
                  athleteId: 'ath1',
                  login: 'athlete1',
                  fullName: 'Athlete One',
                  addedAt: kNow,
                ));
        when(() => groupsRepo.getGroup(groupId: 'g1'))
            .thenAnswer((_) async => makeGroupDetail());
        when(() => trainingRepo.getAssignments(groupId: 'g1', pageSize: 50))
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
          const GroupMemberAdded(groupId: 'g1', athleteId: 'ath1')),
      verify: (_) => verify(
              () => groupsRepo.addMember(groupId: 'g1', athleteId: 'ath1'))
          .called(1),
    );

    blocTest<GroupDetailBloc, GroupDetailState>(
      'GroupMemberRemoved calls removeMember and reloads',
      build: () {
        when(() => groupsRepo.removeMember(groupId: 'g1', athleteId: 'ath1'))
            .thenAnswer((_) async {});
        when(() => groupsRepo.getGroup(groupId: 'g1'))
            .thenAnswer((_) async => makeGroupDetail());
        when(() => trainingRepo.getAssignments(groupId: 'g1', pageSize: 50))
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
          const GroupMemberRemoved(groupId: 'g1', athleteId: 'ath1')),
      verify: (_) => verify(
              () => groupsRepo.removeMember(groupId: 'g1', athleteId: 'ath1'))
          .called(1),
    );
  });
}
