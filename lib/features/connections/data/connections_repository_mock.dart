import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../../auth/domain/models/user.dart';
import '../domain/connections_repository.dart';
import '../domain/models/athlete_info.dart';
import '../domain/models/coach_info.dart';
import '../domain/models/connection_request.dart';

class ConnectionsRepositoryMock implements ConnectionsRepository {
  final _athletes = [
    AthleteInfo(
      id: '22222222-2222-2222-2222-222222222222',
      login: 'ivan-petrov',
      fullName: 'Петров Иван Сергеевич',
      connectedAt: DateTime(2026, 2, 20),
    ),
    AthleteInfo(
      id: '33333333-3333-3333-3333-333333333333',
      login: 'anna-smirnova',
      fullName: 'Смирнова Анна Дмитриевна',
      connectedAt: DateTime(2026, 3, 1),
    ),
    AthleteInfo(
      id: '44444444-4444-4444-4444-444444444444',
      login: 'alex-kuznetsov',
      fullName: 'Кузнецов Алексей Павлович',
      connectedAt: DateTime(2026, 3, 10),
    ),
  ];

  final _requests = [
    ConnectionRequest(
      id: 'req-1',
      athlete: const ConnectionUser(
        id: '55555555-5555-5555-5555-555555555555',
        login: 'daria-volkova',
        fullName: 'Волкова Дарья Игоревна',
      ),
      coach: const ConnectionUser(
        id: '11111111-1111-1111-1111-111111111111',
        login: 'coach-maria',
        fullName: 'Сидорова Мария Александровна',
      ),
      status: 'pending',
      createdAt: DateTime(2026, 3, 28),
    ),
  ];

  @override
  Future<PaginatedResult<User>> searchUsers({
    required String query,
    String? role,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final coaches = [
      User.fromJson(const {
        'id': '11111111-1111-1111-1111-111111111111',
        'login': 'coach-maria',
        'email': 'maria@example.com',
        'full_name': 'Сидорова Мария Александровна',
        'role': 'coach',
        'created_at': '2026-01-15T10:00:00Z',
      }),
      User.fromJson(const {
        'id': '66666666-6666-6666-6666-666666666666',
        'login': 'coach-sergey',
        'email': 'sergey@example.com',
        'full_name': 'Козлов Сергей Николаевич',
        'role': 'coach',
        'created_at': '2026-01-10T10:00:00Z',
      }),
    ];
    final q = query.toLowerCase();
    final filtered = coaches
        .where((u) =>
            u.fullName.toLowerCase().contains(q) ||
            u.login.toLowerCase().contains(q))
        .toList();
    return PaginatedResult(
      items: filtered,
      pagination: Pagination(
          page: 1,
          pageSize: pageSize,
          totalItems: filtered.length,
          totalPages: 1),
    );
  }

  @override
  Future<ConnectionRequest> sendConnectionRequest(
      {required String coachId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return ConnectionRequest(
      id: 'req-new',
      athlete: const ConnectionUser(
        id: '22222222-2222-2222-2222-222222222222',
        login: 'ivan-petrov',
        fullName: 'Петров Иван Сергеевич',
      ),
      coach: ConnectionUser(
        id: coachId,
        login: 'coach',
        fullName: 'Тренер',
      ),
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaginatedResult<ConnectionRequest>> getIncomingRequests({
    String status = 'pending',
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PaginatedResult(
      items: _requests,
      pagination: Pagination(
          page: 1,
          pageSize: pageSize,
          totalItems: _requests.length,
          totalPages: 1),
    );
  }

  @override
  Future<ConnectionRequest?> getOutgoingRequest() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return null;
  }

  @override
  Future<ConnectionRequest> acceptRequest({required String requestId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requests.removeWhere((r) => r.id == requestId);
    return ConnectionRequest(
      id: requestId,
      athlete: const ConnectionUser(
          id: 'x', login: 'x', fullName: 'x'),
      coach: const ConnectionUser(
          id: 'x', login: 'x', fullName: 'x'),
      status: 'accepted',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ConnectionRequest> rejectRequest({required String requestId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requests.removeWhere((r) => r.id == requestId);
    return ConnectionRequest(
      id: requestId,
      athlete: const ConnectionUser(
          id: 'x', login: 'x', fullName: 'x'),
      coach: const ConnectionUser(
          id: 'x', login: 'x', fullName: 'x'),
      status: 'rejected',
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<PaginatedResult<AthleteInfo>> getCoachAthletes({
    String? query,
    int page = 1,
    int pageSize = 50,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _athletes;
    if (query != null && query.isNotEmpty) {
      final q = query.toLowerCase();
      list = list
          .where((a) =>
              a.fullName.toLowerCase().contains(q) ||
              a.login.toLowerCase().contains(q))
          .toList();
    }
    return PaginatedResult(
      items: list,
      pagination: Pagination(
          page: 1,
          pageSize: pageSize,
          totalItems: list.length,
          totalPages: 1),
    );
  }

  @override
  Future<CoachInfo> getAthleteCoach() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return CoachInfo(
      id: '11111111-1111-1111-1111-111111111111',
      login: 'coach-maria',
      fullName: 'Сидорова Мария Александровна',
      connectedAt: DateTime(2026, 2, 20),
    );
  }

  @override
  Future<void> removeAthlete({required String athleteId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _athletes.removeWhere((a) => a.id == athleteId);
  }
}
