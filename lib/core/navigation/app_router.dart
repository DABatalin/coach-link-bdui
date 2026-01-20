import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/athlete_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/connections/presentation/screens/athletes_list_screen.dart';
import '../../features/connections/presentation/screens/find_coach_screen.dart';
import '../../features/connections/presentation/screens/my_coach_screen.dart';
import '../../features/connections/presentation/screens/pending_requests_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/training/presentation/screens/archived_assignments_screen.dart';
import '../../features/training/presentation/screens/assignment_detail_screen.dart';
import '../../features/training/presentation/screens/athlete_assignments_screen.dart';
import '../../features/training/presentation/screens/coach_assignments_screen.dart';
import '../../features/training/presentation/screens/create_plan_screen.dart';
import '../../features/training/presentation/screens/templates_screen.dart';
import '../../features/reports/presentation/screens/submit_report_screen.dart';
import '../../features/reports/presentation/screens/view_report_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../auth/auth_state.dart';
import '../di/auth_providers.dart';
import 'routes.dart';
import 'shell_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final auth = authState.valueOrNull;
      final isOnAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (auth == null || auth is AuthInitial) return null;
      if (auth is Unauthenticated && !isOnAuth) return AppRoutes.login;
      if (auth is Authenticated && isOnAuth) {
        return auth.isCoach
            ? AppRoutes.coachDashboard
            : AppRoutes.athleteDashboard;
      }
      if (auth is Authenticated && auth.isCoach) {
        if (state.matchedLocation.startsWith('/athlete')) {
          return AppRoutes.coachDashboard;
        }
      }
      if (auth is Authenticated && auth.isAthlete) {
        if (state.matchedLocation.startsWith('/coach')) {
          return AppRoutes.athleteDashboard;
        }
      }
      if (state.matchedLocation == '/' && auth is Authenticated) {
        return auth.isCoach
            ? AppRoutes.coachDashboard
            : AppRoutes.athleteDashboard;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterScreen(),
      ),

      // Coach shell
      ShellRoute(
        builder: (_, state, child) => ShellScaffold(
          currentLocation: state.matchedLocation,
          role: 'coach',
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.coachDashboard,
            builder: (_, __) => const CoachDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAssignments,
            builder: (_, __) => const CoachAssignmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachGroups,
            builder: (_, __) => const GroupsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (_, __) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAthletes,
            builder: (_, __) => const AthletesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachRequests,
            builder: (_, __) => const PendingRequestsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAssignmentDetail,
            builder: (_, state) => AssignmentDetailScreen(
                assignmentId: state.pathParameters['id']!, isCoach: true),
          ),
          GoRoute(
            path: AppRoutes.coachAssignmentReport,
            builder: (_, state) => ViewReportScreen(
                assignmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.coachArchived,
            builder: (_, __) => const ArchivedAssignmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachTemplates,
            builder: (_, __) => const TemplatesScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachTemplateCreate,
            builder: (_, __) => const TemplatesScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachPlanCreate,
            builder: (_, __) => const CreatePlanScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachGroupDetail,
            builder: (_, state) => GroupDetailScreen(
                groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
        ],
      ),

      // Athlete shell
      ShellRoute(
        builder: (_, state, child) => ShellScaffold(
          currentLocation: state.matchedLocation,
          role: 'athlete',
          child: child,
        ),
        routes: [
          GoRoute(
            path: AppRoutes.athleteDashboard,
            builder: (_, __) => const AthleteDashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteAssignments,
            builder: (_, __) => const AthleteAssignmentsScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteGroups,
            builder: (_, __) => const GroupsListScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteAssignmentDetail,
            builder: (_, state) => AssignmentDetailScreen(
                assignmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.athleteReportSubmit,
            builder: (_, state) => SubmitReportScreen(
                assignmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.athleteFindCoach,
            builder: (_, __) => const FindCoachScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteMyCoach,
            builder: (_, __) => const MyCoachScreen(),
          ),
        ],
      ),
    ],
  );
});
