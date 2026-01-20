import '../../../shared/models/paginated_result.dart';
import 'models/training_group.dart';

abstract class GroupsRepository {
  Future<PaginatedResult<TrainingGroupSummary>> getGroups({
    int page = 1,
    int pageSize = 20,
  });

  Future<TrainingGroupDetail> getGroup({
    required String groupId,
    String? query,
  });

  Future<TrainingGroupSummary> createGroup({required String name});

  Future<TrainingGroupSummary> updateGroup({
    required String groupId,
    required String name,
  });

  Future<void> deleteGroup({required String groupId});

  Future<GroupMember> addMember({
    required String groupId,
    required String athleteId,
  });

  Future<void> removeMember({
    required String groupId,
    required String athleteId,
  });
}
