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
  });

  final int today;
  final int tomorrow;
  final int pending;
  final int overdue;
  final int completedToday;
  final int upcoming;
  final int favorites;
  final int recentKnowledge;

  int get activeTotal => pending + completedToday;
  double get completionRate =>
      activeTotal == 0 ? 0 : completedToday / activeTotal;
}
