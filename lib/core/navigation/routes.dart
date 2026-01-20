abstract final class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';

  // Coach
  static const coachDashboard = '/coach/dashboard';
  static const coachAthletes = '/coach/athletes';
  static const coachRequests = '/coach/requests';
  static const coachAssignments = '/coach/assignments';
  static const coachAssignmentDetail = '/coach/assignments/:id';
  static const coachAssignmentReport = '/coach/assignments/:id/report';
  static const coachArchived = '/coach/archived';
  static const coachTemplates = '/coach/templates';
  static const coachTemplateCreate = '/coach/templates/create';
  static const coachPlanCreate = '/coach/plans/create';
  static const coachGroups = '/coach/groups';
  static const coachGroupDetail = '/coach/groups/:id';

  // Athlete
  static const athleteDashboard = '/athlete/dashboard';
  static const athleteAssignments = '/athlete/assignments';
  static const athleteAssignmentDetail = '/athlete/assignments/:id';
  static const athleteReportSubmit = '/athlete/assignments/:id/report/submit';
  static const athleteFindCoach = '/athlete/find-coach';
  static const athleteMyCoach = '/athlete/my-coach';
  static const athleteGroups = '/athlete/groups';

  // Shared
  static const profile = '/profile';
  static const notifications = '/notifications';
}
