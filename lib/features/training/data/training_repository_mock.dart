import '../../../shared/models/paginated_result.dart';
import '../../../shared/models/pagination.dart';
import '../domain/models/assignment.dart';
import '../domain/models/training_template.dart';
import '../domain/training_repository.dart';

class TrainingRepositoryMock implements TrainingRepository {
  final _assignments = <AssignmentListItem>[
    AssignmentListItem(
      id: 'a-1',
      planId: 'p-1',
      title: 'Развивающий кросс 8 км',
      scheduledDate: DateTime.now().add(const Duration(days: 1)),
      status: 'assigned',
      isOverdue: false,
      hasReport: false,
      assignedAt: DateTime.now().subtract(const Duration(hours: 2)),
      athleteId: '22222222-2222-2222-2222-222222222222',
      athleteFullName: 'Петров Иван Сергеевич',
      athleteLogin: 'ivan-petrov',
      coachFullName: 'Сидорова Мария Александровна',
      coachLogin: 'coach-maria',
    ),
    AssignmentListItem(
      id: 'a-2',
      planId: 'p-2',
      title: 'Интервалы 10x400м',
      scheduledDate: DateTime.now().subtract(const Duration(days: 2)),
      status: 'assigned',
      isOverdue: true,
      hasReport: false,
      assignedAt: DateTime.now().subtract(const Duration(days: 3)),
      athleteId: '33333333-3333-3333-3333-333333333333',
      athleteFullName: 'Смирнова Анна Дмитриевна',
      athleteLogin: 'anna-smirnova',
      coachFullName: 'Сидорова Мария Александровна',
      coachLogin: 'coach-maria',
    ),
    AssignmentListItem(
      id: 'a-3',
      planId: 'p-3',
      title: 'Темповый бег 5 км',
      scheduledDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'completed',
      isOverdue: false,
      hasReport: true,
      assignedAt: DateTime.now().subtract(const Duration(days: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 6)),
      athleteId: '22222222-2222-2222-2222-222222222222',
      athleteFullName: 'Петров Иван Сергеевич',
      athleteLogin: 'ivan-petrov',
      coachFullName: 'Сидорова Мария Александровна',
      coachLogin: 'coach-maria',
    ),
  ];

  final _templates = <TrainingTemplate>[
    TrainingTemplate(
      id: 't-1',
      title: 'Развивающий кросс 8 км',
      description:
          'Кросс 8 км в аэробной зоне (пульс 140-155). Разминка 2 км трусцой, основная часть 5 км в темпе 4:30-4:45/км, заминка 1 км.',
      createdAt: DateTime(2026, 3, 1),
    ),
    TrainingTemplate(
      id: 't-2',
      title: 'Интервалы 10x400м',
      description:
          'Разминка 2 км. 10 повторов по 400м через 200м трусцой. Темп 400м — 68-72 сек. Заминка 1.5 км.',
      createdAt: DateTime(2026, 3, 5),
    ),
  ];

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
    await Future.delayed(const Duration(milliseconds: 400));
    final newId = 'a-${_assignments.length + 1}';
    _assignments.insert(
      0,
      AssignmentListItem(
        id: newId,
        planId: 'p-new',
        title: title,
        scheduledDate: scheduledDate,
        status: 'assigned',
        isOverdue: false,
        hasReport: false,
        assignedAt: DateTime.now(),
        athleteFullName: 'Петров Иван Сергеевич',
        athleteLogin: 'ivan-petrov',
      ),
    );
    return {'plan': {'id': 'p-new', 'title': title}, 'assignments': []};
  }

  @override
  Future<PaginatedResult<AssignmentListItem>> getAssignments({
    String? athleteFullName,
    String? athleteLogin,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? status,
    String sortBy = 'date_desc',
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    var list = _assignments.where((a) => a.status != 'archived').toList();
    if (status != null) list = list.where((a) => a.status == status).toList();
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
  Future<PaginatedResult<AssignmentListItem>> getArchivedAssignments({
    String? athleteFullName,
    String? athleteLogin,
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PaginatedResult(
      items: const [],
      pagination:
          Pagination(page: 1, pageSize: pageSize, totalItems: 0, totalPages: 0),
    );
  }

  @override
  Future<AssignmentDetail> getAssignment(
      {required String assignmentId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final a = _assignments.firstWhere((a) => a.id == assignmentId);
    return AssignmentDetail(
      id: a.id,
      planId: a.planId,
      title: a.title,
      description:
          'Кросс 8 км в аэробной зоне (пульс 140-155).\n\nРазминка: 2 км трусцой.\nОсновная часть: 5 км в темпе 4:30-4:45/км.\nЗаминка: 1 км.\n\nПульсовая зона: 140-155 уд/мин.',
      scheduledDate: a.scheduledDate,
      status: a.status,
      isOverdue: a.isOverdue,
      hasReport: a.hasReport,
      assignedAt: a.assignedAt,
      completedAt: a.completedAt,
      athleteId: a.athleteId,
      athleteFullName: a.athleteFullName,
      athleteLogin: a.athleteLogin,
      coachFullName: a.coachFullName,
      coachLogin: a.coachLogin,
    );
  }

  @override
  Future<void> deleteAssignment({required String assignmentId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _assignments.removeWhere((a) => a.id == assignmentId);
  }

  @override
  Future<void> archiveAssignment({required String assignmentId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Future<PaginatedResult<TrainingTemplate>> getTemplates({
    String? query,
    int page = 1,
    int pageSize = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return PaginatedResult(
      items: _templates,
      pagination: Pagination(
          page: 1,
          pageSize: pageSize,
          totalItems: _templates.length,
          totalPages: 1),
    );
  }

  @override
  Future<TrainingTemplate> getTemplate({required String templateId}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _templates.firstWhere((t) => t.id == templateId);
  }

  @override
  Future<TrainingTemplate> createTemplate({
    required String title,
    required String description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final t = TrainingTemplate(
        id: 't-${_templates.length + 1}',
        title: title,
        description: description,
        createdAt: DateTime.now());
    _templates.add(t);
    return t;
  }

  @override
  Future<TrainingTemplate> updateTemplate({
    required String templateId,
    String? title,
    String? description,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _templates.firstWhere((t) => t.id == templateId);
  }

  @override
  Future<void> deleteTemplate({required String templateId}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _templates.removeWhere((t) => t.id == templateId);
  }
}
