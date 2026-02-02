import 'package:dio/dio.dart';

import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../domain/models/assignment.dart';
import '../domain/models/training_template.dart';
import '../domain/training_repository.dart';

class TrainingRepositoryImpl implements TrainingRepository {
  TrainingRepositoryImpl(this._dio);
  final Dio _dio;

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Future<Map<String, dynamic>> createPlan({
    required String title,
    required String description,
    required DateTime scheduledDate,
    List<String>? athleteIds,
    String? groupId,
    String? templateId,
    bool saveAsTemplate = false,
  }) async {
    final response = await _dio.post('/api/v1/training/plans', data: {
      'title': title,
      'description': description,
      'scheduled_date': _formatDate(scheduledDate),
      if (athleteIds != null && athleteIds.isNotEmpty) 'athlete_ids': athleteIds,
      if (groupId != null) 'group_id': groupId,
      if (templateId != null) 'template_id': templateId,
      'save_as_template': saveAsTemplate,
    });
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<PaginatedResult<AssignmentListItem>> getAssignments({
    String? athleteFullName,
    String? athleteLogin,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    String? groupId,
    String sortBy = 'date_desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response =
        await _dio.get('/api/v1/training/assignments', queryParameters: {
      if (athleteFullName != null) 'athlete_full_name': athleteFullName,
      if (athleteLogin != null) 'athlete_login': athleteLogin,
      if (dateFrom != null) 'date_from': _formatDate(dateFrom),
      if (dateTo != null) 'date_to': _formatDate(dateTo),
      if (status != null) 'status': status,
      if (groupId != null) 'group_id': groupId,
      'sort_by': sortBy,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => AssignmentListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<PaginatedResult<AssignmentListItem>> getArchivedAssignments({
    String? athleteFullName,
    String? athleteLogin,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio
        .get('/api/v1/training/assignments/archived', queryParameters: {
      if (athleteFullName != null) 'athlete_full_name': athleteFullName,
      if (athleteLogin != null) 'athlete_login': athleteLogin,
      if (dateFrom != null) 'date_from': _formatDate(dateFrom),
      if (dateTo != null) 'date_to': _formatDate(dateTo),
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => AssignmentListItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<AssignmentDetail> getAssignment({required String assignmentId}) async {
    final response =
        await _dio.get('/api/v1/training/assignments/$assignmentId');
    return AssignmentDetail.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteAssignment({required String assignmentId}) async {
    await _dio.delete('/api/v1/training/assignments/$assignmentId');
  }

  @override
  Future<void> archiveAssignment({required String assignmentId}) async {
    await _dio.put('/api/v1/training/assignments/$assignmentId/archive');
  }

  @override
  Future<PaginatedResult<TrainingTemplate>> getTemplates({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response =
        await _dio.get('/api/v1/training/templates', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => TrainingTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<TrainingTemplate> getTemplate({required String templateId}) async {
    final response =
        await _dio.get('/api/v1/training/templates/$templateId');
    return TrainingTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TrainingTemplate> createTemplate({
    required String title,
    required String description,
  }) async {
    final response = await _dio.post('/api/v1/training/templates', data: {
      'title': title,
      'description': description,
    });
    return TrainingTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<TrainingTemplate> updateTemplate({
    required String templateId,
    String? title,
    String? description,
  }) async {
    final response =
        await _dio.put('/api/v1/training/templates/$templateId', data: {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
    });
    return TrainingTemplate.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteTemplate({required String templateId}) async {
    await _dio.delete('/api/v1/training/templates/$templateId');
  }
}
