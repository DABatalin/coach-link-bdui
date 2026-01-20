import 'package:dio/dio.dart';

import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../../auth/domain/models/user.dart';
import '../domain/connections_repository.dart';
import '../domain/models/athlete_info.dart';
import '../domain/models/coach_info.dart';
import '../domain/models/connection_request.dart';

class ConnectionsRepositoryImpl implements ConnectionsRepository {
  ConnectionsRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<PaginatedResult<User>> searchUsers({
    required String query,
    String? role,
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get('/api/v1/users/search', queryParameters: {
      'q': query,
      if (role != null) 'role': role,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<ConnectionRequest> sendConnectionRequest(
      {required String coachId}) async {
    final response = await _dio.post(
      '/api/v1/connections/request',
      data: {'coach_id': coachId},
    );
    return ConnectionRequest.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PaginatedResult<ConnectionRequest>> getIncomingRequests({
    String status = 'pending',
    int page = 1,
    int pageSize = 20,
  }) async {
    final response =
        await _dio.get('/api/v1/connections/requests/incoming', queryParameters: {
      'status': status,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => ConnectionRequest.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<ConnectionRequest?> getOutgoingRequest() async {
    try {
      final response =
          await _dio.get('/api/v1/connections/requests/outgoing');
      return ConnectionRequest.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<ConnectionRequest> acceptRequest({required String requestId}) async {
    final response = await _dio
        .put('/api/v1/connections/requests/$requestId/accept');
    return ConnectionRequest.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<ConnectionRequest> rejectRequest({required String requestId}) async {
    final response = await _dio
        .put('/api/v1/connections/requests/$requestId/reject');
    return ConnectionRequest.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<PaginatedResult<AthleteInfo>> getCoachAthletes({
    String? query,
    int page = 1,
    int pageSize = 50,
  }) async {
    final response =
        await _dio.get('/api/v1/connections/athletes', queryParameters: {
      if (query != null && query.isNotEmpty) 'q': query,
      'page': page,
      'page_size': pageSize,
    });
    final data = response.data as Map<String, dynamic>;
    return PaginatedResult(
      items: ((data['items'] as List?) ?? [])
          .map((e) => AthleteInfo.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination:
          Pagination.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }

  @override
  Future<CoachInfo> getAthleteCoach() async {
    final response = await _dio.get('/api/v1/connections/coach');
    return CoachInfo.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> removeAthlete({required String athleteId}) async {
    await _dio.delete('/api/v1/connections/athletes/$athleteId');
  }
}
