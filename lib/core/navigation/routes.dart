abstract final class AppRoutes {
  // Auth
  static const login = '/login';
  static const register = '/register';

  // Coach
  static const coachDashboard = '/coach/dashboard';
  static const coachAthletes = '/coach/athletes';
  static const coachAthleteDetail = '/coach/athletes/:id';
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
  static const coachProfile = '/coach/profile';
  static const coachNotifications = '/coach/notifications';
  static const coachAthleteStats = '/coach/athletes/:id/stats';
  static const coachAthleteAi = '/coach/athletes/:id/ai';
  static const coachAiSummary = '/coach/ai-summary';

  // Athlete
  static const athleteDashboard = '/athlete/dashboard';
  static const athleteAssignments = '/athlete/assignments';
  static const athleteAssignmentDetail = '/athlete/assignments/:id';
  static const athleteReportSubmit = '/athlete/assignments/:id/report/submit';
  static const athleteFindCoach = '/athlete/find-coach';
  static const athleteMyCoach = '/athlete/my-coach';
  static const athleteGroups = '/athlete/groups';
  static const athleteProfile = '/athlete/profile';
  static const athleteNotifications = '/athlete/notifications';
  static const athleteMyStats = '/athlete/my-stats';

  // Legacy aliases (redirect targets based on role, use in code where role is known)
  static const profile = '/coach/profile';
  static const notifications = '/coach/notifications';
}
