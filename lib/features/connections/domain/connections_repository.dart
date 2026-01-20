import '../../../shared/models/paginated_result.dart';
import '../../auth/domain/models/user.dart';
import 'models/athlete_info.dart';
import 'models/coach_info.dart';
import 'models/connection_request.dart';

abstract class ConnectionsRepository {
  Future<PaginatedResult<User>> searchUsers({
    required String query,
    String? role,
    int page = 1,
    int pageSize = 20,
  });

  Future<ConnectionRequest> sendConnectionRequest({required String coachId});

  Future<PaginatedResult<ConnectionRequest>> getIncomingRequests({
    String status = 'pending',
    int page = 1,
    int pageSize = 20,
  });

  Future<ConnectionRequest?> getOutgoingRequest();

  Future<ConnectionRequest> acceptRequest({required String requestId});

  Future<ConnectionRequest> rejectRequest({required String requestId});

  Future<PaginatedResult<AthleteInfo>> getCoachAthletes({
    String? query,
    int page = 1,
    int pageSize = 50,
  });

  Future<CoachInfo> getAthleteCoach();

  Future<void> removeAthlete({required String athleteId});
}
