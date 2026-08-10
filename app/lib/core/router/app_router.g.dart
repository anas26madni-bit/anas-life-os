// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $foundationRoute,
  $searchRoute,
  $appShellRoute,
];

RouteBase get $foundationRoute => GoRouteData.$route(
  path: '/',
  hasOverriddenOnExit: false,
  factory: $FoundationRoute._fromState,
);

mixin $FoundationRoute on GoRouteData {
  static FoundationRoute _fromState(GoRouterState state) =>
      const FoundationRoute();

  @override
  String get location => GoRouteData.$location('/');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $searchRoute => GoRouteData.$route(
  path: '/search',
  hasOverriddenOnExit: false,
  parentNavigatorKey: SearchRoute.$parentNavigatorKey,
  factory: $SearchRoute._fromState,
);

mixin $SearchRoute on GoRouteData {
  static SearchRoute _fromState(GoRouterState state) => const SearchRoute();

  @override
  String get location => GoRouteData.$location('/search');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $appShellRoute => StatefulShellRouteData.$route(
  restorationScopeId: AppShellRoute.$restorationScopeId,
  factory: $AppShellRouteExtension._fromState,
  branches: [
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/dashboard',
          hasOverriddenOnExit: false,
          factory: $DashboardRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/tasks',
          hasOverriddenOnExit: false,
          factory: $TasksRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'new',
              hasOverriddenOnExit: false,
              factory: $TaskCreateRoute._fromState,
            ),
            GoRouteData.$route(
              path: ':taskId',
              hasOverriddenOnExit: false,
              factory: $TaskDetailRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/calendar',
          hasOverriddenOnExit: false,
          factory: $CalendarRoute._fromState,
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/knowledge',
          hasOverriddenOnExit: false,
          factory: $KnowledgeRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'notes/:noteId',
              hasOverriddenOnExit: false,
              factory: $KnowledgeDetailRoute._fromState,
            ),
          ],
        ),
      ],
    ),
    StatefulShellBranchData.$branch(
      routes: [
        GoRouteData.$route(
          path: '/more',
          hasOverriddenOnExit: false,
          factory: $MoreRoute._fromState,
          routes: [
            GoRouteData.$route(
              path: 'projects',
              hasOverriddenOnExit: false,
              factory: $ProjectsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':projectId',
                  hasOverriddenOnExit: false,
                  factory: $ProjectDetailRoute._fromState,
                  routes: [
                    GoRouteData.$route(
                      path: 'statistics',
                      hasOverriddenOnExit: false,
                      factory: $ProjectStatisticsRoute._fromState,
                    ),
                  ],
                ),
              ],
            ),
            GoRouteData.$route(
              path: 'reminders',
              hasOverriddenOnExit: false,
              factory: $RemindersRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'statistics',
              hasOverriddenOnExit: false,
              factory: $StatisticsRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'backup',
              hasOverriddenOnExit: false,
              factory: $BackupRoute._fromState,
            ),
            GoRouteData.$route(
              path: 'documents',
              hasOverriddenOnExit: false,
              factory: $DocumentsRoute._fromState,
              routes: [
                GoRouteData.$route(
                  path: ':documentId',
                  hasOverriddenOnExit: false,
                  factory: $DocumentDetailRoute._fromState,
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

extension $AppShellRouteExtension on AppShellRoute {
  static AppShellRoute _fromState(GoRouterState state) => const AppShellRoute();
}

mixin $DashboardRoute on GoRouteData {
  static DashboardRoute _fromState(GoRouterState state) =>
      const DashboardRoute();

  @override
  String get location => GoRouteData.$location('/dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TasksRoute on GoRouteData {
  static TasksRoute _fromState(GoRouterState state) => const TasksRoute();

  @override
  String get location => GoRouteData.$location('/tasks');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TaskCreateRoute on GoRouteData {
  static TaskCreateRoute _fromState(GoRouterState state) =>
      const TaskCreateRoute();

  @override
  String get location => GoRouteData.$location('/tasks/new');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $TaskDetailRoute on GoRouteData {
  static TaskDetailRoute _fromState(GoRouterState state) =>
      TaskDetailRoute(int.parse(state.pathParameters['taskId']!));

  TaskDetailRoute get _self => this as TaskDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/tasks/${Uri.encodeComponent(_self.taskId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $CalendarRoute on GoRouteData {
  static CalendarRoute _fromState(GoRouterState state) => const CalendarRoute();

  @override
  String get location => GoRouteData.$location('/calendar');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $KnowledgeRoute on GoRouteData {
  static KnowledgeRoute _fromState(GoRouterState state) =>
      const KnowledgeRoute();

  @override
  String get location => GoRouteData.$location('/knowledge');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $KnowledgeDetailRoute on GoRouteData {
  static KnowledgeDetailRoute _fromState(GoRouterState state) =>
      KnowledgeDetailRoute(int.parse(state.pathParameters['noteId']!));

  KnowledgeDetailRoute get _self => this as KnowledgeDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/knowledge/notes/${Uri.encodeComponent(_self.noteId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $MoreRoute on GoRouteData {
  static MoreRoute _fromState(GoRouterState state) => const MoreRoute();

  @override
  String get location => GoRouteData.$location('/more');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProjectsRoute on GoRouteData {
  static ProjectsRoute _fromState(GoRouterState state) => const ProjectsRoute();

  @override
  String get location => GoRouteData.$location('/more/projects');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProjectDetailRoute on GoRouteData {
  static ProjectDetailRoute _fromState(GoRouterState state) =>
      ProjectDetailRoute(int.parse(state.pathParameters['projectId']!));

  ProjectDetailRoute get _self => this as ProjectDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/more/projects/${Uri.encodeComponent(_self.projectId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $ProjectStatisticsRoute on GoRouteData {
  static ProjectStatisticsRoute _fromState(GoRouterState state) =>
      ProjectStatisticsRoute(int.parse(state.pathParameters['projectId']!));

  ProjectStatisticsRoute get _self => this as ProjectStatisticsRoute;

  @override
  String get location => GoRouteData.$location(
    '/more/projects/${Uri.encodeComponent(_self.projectId.toString())}/statistics',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $RemindersRoute on GoRouteData {
  static RemindersRoute _fromState(GoRouterState state) =>
      const RemindersRoute();

  @override
  String get location => GoRouteData.$location('/more/reminders');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $StatisticsRoute on GoRouteData {
  static StatisticsRoute _fromState(GoRouterState state) =>
      const StatisticsRoute();

  @override
  String get location => GoRouteData.$location('/more/statistics');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $BackupRoute on GoRouteData {
  static BackupRoute _fromState(GoRouterState state) => const BackupRoute();

  @override
  String get location => GoRouteData.$location('/more/backup');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DocumentsRoute on GoRouteData {
  static DocumentsRoute _fromState(GoRouterState state) =>
      const DocumentsRoute();

  @override
  String get location => GoRouteData.$location('/more/documents');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

mixin $DocumentDetailRoute on GoRouteData {
  static DocumentDetailRoute _fromState(GoRouterState state) =>
      DocumentDetailRoute(int.parse(state.pathParameters['documentId']!));

  DocumentDetailRoute get _self => this as DocumentDetailRoute;

  @override
  String get location => GoRouteData.$location(
    '/more/documents/${Uri.encodeComponent(_self.documentId.toString())}',
  );

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
