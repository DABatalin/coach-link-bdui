import 'package:dio/dio.dart';

import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../domain/groups_repository.dart';
import '../domain/models/training_group.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  GroupsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<PaginatedResult<TrainingGroupSummary>> getGroups({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get('/api/v1/groups', queryParameters: {
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: (data['items'] as List)
          .map((e) =>
              TrainingGroupSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<TrainingGroupDetail> getGroup({
    required String groupId,
    String? query,
  }) async {
    final response = await _dio.get('/api/v1/groups/$groupId', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
    });
    return TrainingGroupDetail.fromJson(
        response.data as Map<String, dynamic>);
  }

  @override
  Future<TrainingGroupSummary> createGroup({required String name}) async {
    final response = await _dio.post('/api/v1/groups', data: {'name': name});
    // API returns TrainingGroup, we map to summary with 0 members
    final data = response.data as Map<String, dynamic>;
    return TrainingGroupSummary(
      id: data['id'] as String,
      name: data['name'] as String,
      membersCount: 0,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<TrainingGroupSummary> updateGroup({
    required String groupId,
    required String name,
  }) async {
    final response = await _dio.put('/api/v1/groups/$groupId', data: {'name': name});
    final data = response.data as Map<String, dynamic>;
    return TrainingGroupSummary(
      id: data['id'] as String,
      name: data['name'] as String,
      membersCount: 0,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  @override
  Future<void> deleteGroup({required String groupId}) async {
    await _dio.delete('/api/v1/groups/$groupId');
  }

  @override
  Future<GroupMember> addMember({
    required String groupId,
    required String athleteId,
  }) async {
    final response = await _dio.post(
      '/api/v1/groups/$groupId/members',
      data: {'athlete_id': athleteId},
    );
    return GroupMember.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeMember({
    required String groupId,
    required String athleteId,
  }) async {
    await _dio.delete('/api/v1/groups/$groupId/members/$athleteId');
  }
}
