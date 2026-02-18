import 'package:bloc_test/bloc_test.dart';
import 'package:coach_link/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_data.dart';

void main() {
  late MockGroupsRepository groupsRepo;

  setUp(() {
    groupsRepo = MockGroupsRepository();
  });

  GroupsBloc buildBloc() => GroupsBloc(repository: groupsRepo);

  group('GroupsBloc', () {
    test('initial state is GroupsInitial', () {
      expect(buildBloc().state, isA<GroupsInitial>());
    });

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Loaded] with groups list',
      build: () {
        when(() => groupsRepo.getGroups()).thenAnswer(
          (_) async => makePaginated([
            makeGroupSummary(id: 'g1', name: 'Group A'),
            makeGroupSummary(id: 'g2', name: 'Group B'),
          ]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupsLoadRequested()),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsLoaded>().having((s) => s.groups.length, 'length', 2),
      ],
    );

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Loaded(empty)] when no groups',
      build: () {
        when(() => groupsRepo.getGroups())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupsLoadRequested()),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsLoaded>().having((s) => s.groups, 'groups', isEmpty),
      ],
    );

    blocTest<GroupsBloc, GroupsState>(
      'emits [Loading, Error] when repository throws',
      build: () {
        when(() => groupsRepo.getGroups()).thenThrow(Exception('Network error'));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupsLoadRequested()),
      expect: () => [isA<GroupsLoading>(), isA<GroupsError>()],
    );

    blocTest<GroupsBloc, GroupsState>(
      'GroupCreated calls createGroup and reloads list',
      build: () {
        when(() => groupsRepo.createGroup(name: 'New Group'))
            .thenAnswer((_) async => makeGroupSummary(name: 'New Group'));
        when(() => groupsRepo.getGroups()).thenAnswer(
          (_) async => makePaginated([makeGroupSummary(name: 'New Group')]),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupCreated('New Group')),
      expect: () => [
        isA<GroupsLoading>(),
        isA<GroupsLoaded>().having((s) => s.groups.length, 'length', 1),
      ],
      verify: (_) =>
          verify(() => groupsRepo.createGroup(name: 'New Group')).called(1),
    );

    blocTest<GroupsBloc, GroupsState>(
      'GroupDeleted calls deleteGroup and reloads list',
      build: () {
        when(() => groupsRepo.deleteGroup(groupId: 'g1'))
            .thenAnswer((_) async {});
        when(() => groupsRepo.getGroups())
            .thenAnswer((_) async => makePaginated([]));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const GroupDeleted('g1')),
      verify: (_) =>
          verify(() => groupsRepo.deleteGroup(groupId: 'g1')).called(1),
    );
  });
}
