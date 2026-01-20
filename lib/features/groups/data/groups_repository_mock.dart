import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../domain/groups_repository.dart';
import '../domain/models/training_group.dart';

class GroupsRepositoryMock implements GroupsRepository {
  final _groups = <_MockGroup>[
    _MockGroup(
      id: 'g-1',
      name: 'Спринтеры U18',
      members: [
        GroupMember(
            athleteId: '22222222-2222-2222-2222-222222222222',
            login: 'ivan-petrov',
            fullName: 'Петров Иван Сергеевич',
            addedAt: DateTime(2026, 2, 25)),
        GroupMember(
            athleteId: '33333333-3333-3333-3333-333333333333',
            login: 'anna-smirnova',
            fullName: 'Смирнова Анна Дмитриевна',
            addedAt: DateTime(2026, 3, 1)),
      ],
    ),
    _MockGroup(
      id: 'g-2',
      name: 'Стайеры',
      members: [
        GroupMember(
            athleteId: '44444444-4444-4444-4444-444444444444',
            login: 'alex-kuznetsov',
            fullName: 'Кузнецов Алексей Павлович',
            addedAt: DateTime(2026, 3, 10)),
      ],
    ),
  ];

  @override
  Future<PaginatedResult<TrainingGroupSummary>> getGroups({
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final items = _groups
        .map((g) => TrainingGroupSummary(
            id: g.id,
            name: g.name,
            membersCount: g.members.length,
            createdAt: DateTime(2026, 2, 1)))
        .toList();
    return PaginatedResult(
      items: items,
      pagination: Pagination(
          page: 1,
          pageSize: pageSize,
          totalItems: items.length,
          totalPages: 1),
    );
  }

  @override
  Future<TrainingGroupDetail> getGroup({
    required String groupId,
    String? query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final g = _groups.firstWhere((g) => g.id == groupId);
    return TrainingGroupDetail(
      id: g.id,
      name: g.name,
      members: g.members,
      createdAt: DateTime(2026, 2, 1),
    );
  }

  @override
  Future<TrainingGroupSummary> createGroup({required String name}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final id = 'g-${_groups.length + 1}';
    _groups.add(_MockGroup(id: id, name: name, members: []));
    return TrainingGroupSummary(
        id: id, name: name, membersCount: 0, createdAt: DateTime.now());
  }

  @override
  Future<TrainingGroupSummary> updateGroup({
    required String groupId,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final g = _groups.firstWhere((g) => g.id == groupId);
    final updated = _MockGroup(id: g.id, name: name, members: g.members);
    _groups[_groups.indexOf(g)] = updated;
    return TrainingGroupSummary(
        id: g.id,
        name: name,
        membersCount: g.members.length,
        createdAt: DateTime(2026, 2, 1));
  }

  @override
  Future<void> deleteGroup({required String groupId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _groups.removeWhere((g) => g.id == groupId);
  }

  @override
  Future<GroupMember> addMember({
    required String groupId,
    required String athleteId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final member = GroupMember(
        athleteId: athleteId,
        login: 'user',
        fullName: 'Новый спортсмен',
        addedAt: DateTime.now());
    _groups.firstWhere((g) => g.id == groupId).members.add(member);
    return member;
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String athleteId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _groups
        .firstWhere((g) => g.id == groupId)
        .members
        .removeWhere((m) => m.athleteId == athleteId);
  }
}

class _MockGroup {
  _MockGroup({required this.id, required this.name, required this.members});
  final String id;
  final String name;
  final List<GroupMember> members;
}
