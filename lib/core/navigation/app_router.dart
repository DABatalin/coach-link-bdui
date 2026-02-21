import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/connections/presentation/screens/athletes_list_screen.dart';
import '../../features/connections/presentation/screens/athlete_detail_screen.dart';
import '../../features/connections/presentation/screens/find_coach_screen.dart';
import '../../features/connections/presentation/screens/my_coach_screen.dart';
import '../../features/connections/presentation/screens/pending_requests_screen.dart';
import '../../features/dashboard/presentation/screens/athlete_dashboard_screen.dart';
import '../../features/dashboard/presentation/screens/coach_dashboard_screen.dart';
import '../../features/groups/presentation/screens/group_detail_screen.dart';
import '../../features/groups/presentation/screens/groups_list_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/reports/presentation/screens/submit_report_screen.dart';
import '../../features/reports/presentation/screens/view_report_screen.dart';
import '../../features/training/presentation/screens/archived_assignments_screen.dart';
import '../../features/training/presentation/screens/assignment_detail_screen.dart';
import '../../features/training/presentation/screens/athlete_assignments_screen.dart';
import '../../features/training/presentation/screens/coach_assignments_screen.dart';
import '../../features/training/presentation/screens/create_plan_screen.dart';
import '../../features/training/presentation/screens/templates_screen.dart';
import '../../features/analytics/presentation/screens/athlete_stats_screen.dart';
import '../../features/analytics/presentation/screens/my_stats_screen.dart';
import '../../features/ai/presentation/screens/ai_athlete_screen.dart';
import '../../features/ai/presentation/screens/ai_summary_screen.dart';
import '../auth/auth_state.dart';
import '../di/auth_providers.dart';
import 'routes.dart';
import 'shell_scaffold.dart';

/// Wraps a widget in a [NoTransitionPage] to eliminate push animation
/// when switching between bottom nav tabs.
Page<void> _noTransition(Widget child) =>
    NoTransitionPage<void>(child: child);

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final auth = authState.valueOrNull;
      final loc = state.matchedLocation;
      final isOnAuth =
          loc == AppRoutes.login || loc == AppRoutes.register;

      if (auth == null || auth is AuthInitial) return null;
      if (auth is Unauthenticated && !isOnAuth) return AppRoutes.login;
      if (auth is Authenticated && isOnAuth) {
        return auth.isCoach
            ? AppRoutes.coachDashboard
            : AppRoutes.athleteDashboard;
      }
      // Coach cannot access athlete routes
      if (auth is Authenticated && auth.isCoach) {
        if (loc.startsWith('/athlete')) return AppRoutes.coachDashboard;
      }
      // Athlete cannot access coach routes
      if (auth is Authenticated && auth.isAthlete) {
        if (loc.startsWith('/coach')) return AppRoutes.athleteDashboard;
      }
      if (loc == '/' && auth is Authenticated) {
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

      // ── Coach shell ──────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => ShellScaffold(
          currentLocation: state.matchedLocation,
          role: 'coach',
          child: child,
        ),
        routes: [
          // Tab routes — no transition
          GoRoute(
            path: AppRoutes.coachDashboard,
            pageBuilder: (_, __) => _noTransition(const CoachDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.coachAssignments,
            pageBuilder: (_, __) =>
                _noTransition(const CoachAssignmentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.coachGroups,
            pageBuilder: (_, __) =>
                _noTransition(const GroupsListScreen(isCoach: true)),
          ),
          GoRoute(
            path: AppRoutes.coachProfile,
            pageBuilder: (_, __) => _noTransition(const ProfileScreen()),
          ),

          // Secondary routes (push transition is fine)
          GoRoute(
            path: AppRoutes.coachAthletes,
            builder: (_, __) => const AthletesListScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAthleteDetail,
            builder: (_, state) => AthleteDetailScreen(
              athleteId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.coachRequests,
            builder: (_, __) => const PendingRequestsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAssignmentDetail,
            builder: (_, state) => AssignmentDetailScreen(
              assignmentId: state.pathParameters['id']!,
              isCoach: true,
            ),
          ),
          GoRoute(
            path: AppRoutes.coachAssignmentReport,
            builder: (_, state) =>
                ViewReportScreen(assignmentId: state.pathParameters['id']!),
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
            builder: (_, state) => CreatePlanScreen(
              preselectedGroupId: state.uri.queryParameters['group_id'],
            ),
          ),
          GoRoute(
            path: AppRoutes.coachGroupDetail,
            builder: (_, state) =>
                GroupDetailScreen(groupId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.coachNotifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.coachAthleteStats,
            builder: (_, state) => AthleteStatsScreen(
              athleteId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.coachAthleteAi,
            builder: (_, state) => AiAthleteScreen(
              athleteId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.coachAiSummary,
            builder: (_, __) => const AiSummaryScreen(),
          ),
        ],
      ),

      // ── Athlete shell ─────────────────────────────────────────────
      ShellRoute(
        builder: (_, state, child) => ShellScaffold(
          currentLocation: state.matchedLocation,
          role: 'athlete',
          child: child,
        ),
        routes: [
          // Tab routes — no transition
          GoRoute(
            path: AppRoutes.athleteDashboard,
            pageBuilder: (_, __) =>
                _noTransition(const AthleteDashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.athleteAssignments,
            pageBuilder: (_, __) =>
                _noTransition(const AthleteAssignmentsScreen()),
          ),
          GoRoute(
            path: AppRoutes.athleteGroups,
            pageBuilder: (_, __) => _noTransition(const GroupsListScreen()),
          ),
          GoRoute(
            path: AppRoutes.athleteProfile,
            pageBuilder: (_, __) => _noTransition(const ProfileScreen()),
          ),

          // Secondary routes
          GoRoute(
            path: AppRoutes.athleteAssignmentDetail,
            builder: (_, state) => AssignmentDetailScreen(
              assignmentId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.athleteReportSubmit,
            builder: (_, state) =>
                SubmitReportScreen(assignmentId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: AppRoutes.athleteFindCoach,
            builder: (_, __) => const FindCoachScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteMyCoach,
            builder: (_, __) => const MyCoachScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteNotifications,
            builder: (_, __) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.athleteMyStats,
            builder: (_, __) => const MyStatsScreen(),
          ),
        ],
      ),
    ],
  );
});
