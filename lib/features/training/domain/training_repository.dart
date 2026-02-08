import '../../../shared/models/paginated_result.dart';
import 'models/assignment.dart';
import 'models/training_template.dart';

abstract class TrainingRepository {
  Future<Map<String, dynamic>> createPlan({
    required String title,
    required String description,
    required DateTime scheduledDate,
    List<String>? athleteIds,
    String? groupId,
    String? templateId,
    bool saveAsTemplate = false,
  });

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
  });

  Future<PaginatedResult<AssignmentListItem>> getArchivedAssignments({
    String? athleteFullName,
    String? athleteLogin,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  });

  Future<AssignmentDetail> getAssignment({required String assignmentId});

  Future<void> deleteAssignment({required String assignmentId});

  Future<void> archiveAssignment({required String assignmentId});

  Future<PaginatedResult<TrainingTemplate>> getTemplates({
    String? query,
    int page = 1,
    int pageSize = 20,
  });

  Future<TrainingTemplate> getTemplate({required String templateId});

  Future<TrainingTemplate> createTemplate({
    required String title,
    required String description,
  });

  Future<TrainingTemplate> updateTemplate({
    required String templateId,
    String? title,
    String? description,
  });

  Future<void> deleteTemplate({required String templateId});
}
