enum DashboardWidgetKind {
  today,
  tomorrow,
  pending,
  overdue,
  completedToday,
  upcoming,
  favorites,
  progress,
  recentKnowledge,
  dateTime,
  quickActions,
  miniCalendar,
  recentProjects,
  recentActivity,
  productivity,
}

enum DashboardWidgetSize { compact, regular, expanded }

final class DashboardWidgetPreference {
  const DashboardWidgetPreference({
    required this.kind,
    required this.visible,
    required this.sortOrder,
    required this.size,
  });

  final DashboardWidgetKind kind;
  final bool visible;
  final int sortOrder;
  final DashboardWidgetSize size;

  DashboardWidgetPreference copyWith({
    bool? visible,
    int? sortOrder,
    DashboardWidgetSize? size,
  }) => DashboardWidgetPreference(
    kind: kind,
    visible: visible ?? this.visible,
    sortOrder: sortOrder ?? this.sortOrder,
    size: size ?? this.size,
  );
}

final class DashboardSnapshot {
  const DashboardSnapshot({
    required this.today,
    required this.tomorrow,
    required this.pending,
    required this.overdue,
    required this.completedToday,
    required this.upcoming,
    required this.favorites,
    required this.recentKnowledge,
    this.recentProjects = 0,
    this.recentActivity = 0,
    this.approvedCompletionRate,
    this.approvedProductivityScore,
  });

  final int today;
  final int tomorrow;
  final int pending;
  final int overdue;
  final int completedToday;
  final int upcoming;
  final int favorites;
  final int recentKnowledge;
  final int recentProjects;
  final int recentActivity;
  final double? approvedCompletionRate;
  final int? approvedProductivityScore;

  double? get completionRate => approvedCompletionRate;
  int? get productivityScore => approvedProductivityScore;

  DashboardSnapshot withStatistics({
    required double? completionRate,
    required int? productivityScore,
  }) => DashboardSnapshot(
    today: today,
    tomorrow: tomorrow,
    pending: pending,
    overdue: overdue,
    completedToday: completedToday,
    upcoming: upcoming,
    favorites: favorites,
    recentKnowledge: recentKnowledge,
    recentProjects: recentProjects,
    recentActivity: recentActivity,
    approvedCompletionRate: completionRate,
    approvedProductivityScore: productivityScore,
  );
}
