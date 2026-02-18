import 'package:coach_link/features/auth/domain/models/auth_tokens.dart';
import 'package:coach_link/features/auth/domain/models/user.dart';
import 'package:coach_link/features/connections/domain/models/athlete_info.dart';
import 'package:coach_link/features/connections/domain/models/coach_info.dart';
import 'package:coach_link/features/connections/domain/models/connection_request.dart';
import 'package:coach_link/features/groups/domain/models/training_group.dart';
import 'package:coach_link/features/notifications/domain/models/app_notification.dart';
import 'package:coach_link/features/reports/domain/models/training_report.dart';
import 'package:coach_link/features/training/domain/models/assignment.dart';
import 'package:coach_link/features/training/domain/models/training_template.dart';
import 'package:coach_link/shared/models/paginated_result.dart';
import 'package:coach_link/shared/models/pagination.dart';

final kNow = DateTime(2026, 4, 18);
final kFuture = DateTime(2026, 4, 25);

Pagination makePagination({int totalItems = 0}) => Pagination(
      page: 1,
      pageSize: 20,
      totalItems: totalItems,
      totalPages: totalItems == 0 ? 0 : 1,
    );

PaginatedResult<T> makePaginated<T>(List<T> items) => PaginatedResult(
      items: items,
      pagination: makePagination(totalItems: items.length),
    );

PaginatedResult<T> makePaginatedWithTotal<T>(List<T> items, int totalItems) =>
    PaginatedResult(
      items: items,
      pagination: makePagination(totalItems: totalItems),
    );

User makeUser({
  String id = 'u1',
  String role = 'coach',
  String fullName = 'Test User',
  String login = 'testuser',
}) =>
    User(
      id: id,
      login: login,
      email: 'test@example.com',
      fullName: fullName,
      role: role,
      createdAt: kNow,
    );

AuthTokens makeAuthTokens({String role = 'coach'}) => AuthTokens(
      accessToken: 'access_tok',
      refreshToken: 'refresh_tok',
      expiresIn: 3600,
      user: makeUser(role: role),
    );

AssignmentListItem makeAssignment({
  String id = 'a1',
  String status = 'pending',
  bool isOverdue = false,
  bool hasReport = false,
  String? athleteFullName,
}) =>
    AssignmentListItem(
      id: id,
      planId: 'p1',
      title: 'Test Assignment $id',
      scheduledDate: kFuture,
      status: status,
      isOverdue: isOverdue,
      hasReport: hasReport,
      assignedAt: kNow,
      athleteFullName: athleteFullName,
    );

AthleteInfo makeAthleteInfo({String id = 'ath1'}) => AthleteInfo(
      id: id,
      login: 'athlete1',
      fullName: 'Athlete One',
      connectedAt: kNow,
    );

CoachInfo makeCoachInfo() => CoachInfo(
      id: 'c1',
      login: 'coach1',
      fullName: 'Coach One',
      connectedAt: kNow,
    );

ConnectionRequest makeRequest({
  String id = 'r1',
  String status = 'pending',
}) =>
    ConnectionRequest(
      id: id,
      athlete: const ConnectionUser(id: 'ath1', login: 'athlete1', fullName: 'Athlete One'),
      coach: const ConnectionUser(id: 'c1', login: 'coach1', fullName: 'Coach One'),
      status: status,
      createdAt: kNow,
    );

AppNotification makeNotification({String id = 'n1', bool isRead = false}) =>
    AppNotification(
      id: id,
      type: 'info',
      title: 'Test Notification $id',
      isRead: isRead,
      createdAt: kNow,
    );

TrainingGroupSummary makeGroupSummary({String id = 'g1', String name = 'Test Group'}) =>
    TrainingGroupSummary(
      id: id,
      name: name,
      membersCount: 0,
      createdAt: kNow,
    );

TrainingGroupDetail makeGroupDetail({String id = 'g1', List<GroupMember> members = const []}) =>
    TrainingGroupDetail(
      id: id,
      name: 'Test Group',
      members: members,
      createdAt: kNow,
    );

TrainingReport makeReport() => TrainingReport(
      id: 'rep1',
      assignmentId: 'a1',
      athleteId: 'ath1',
      content: 'Good workout',
      durationMinutes: 60,
      perceivedEffort: 7,
      createdAt: kNow,
    );

TrainingTemplate makeTemplate({String id = 't1'}) => TrainingTemplate(
      id: id,
      title: 'Template $id',
      description: 'Description',
      createdAt: kNow,
    );
