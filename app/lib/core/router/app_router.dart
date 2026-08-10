import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/pages/calendar_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/knowledge/presentation/pages/document_detail_page.dart';
import '../../features/knowledge/presentation/pages/documents_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_detail_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_home_page.dart';
import '../../features/more/presentation/pages/more_page.dart';
import '../../features/reminders/presentation/pages/reminder_list_page.dart';
import '../../features/search/presentation/pages/universal_search_page.dart';
import '../../features/statistics/presentation/pages/statistics_page.dart';
import '../../features/tasks/presentation/pages/project_detail_page.dart';
import '../../features/tasks/presentation/pages/project_list_page.dart';
import '../../features/tasks/presentation/pages/task_create_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../startup/foundation_page.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData with $FoundationRoute {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const FoundationPage();
}

@TypedGoRoute<SearchRoute>(path: '/search')
class SearchRoute extends GoRouteData with $SearchRoute {
  const SearchRoute();

  static final GlobalKey<NavigatorState> $parentNavigatorKey = rootNavigatorKey;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const UniversalSearchPage();
}

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [TypedGoRoute<DashboardRoute>(path: '/dashboard')],
    ),
    TypedStatefulShellBranch<TasksBranch>(
      routes: [
        TypedGoRoute<TasksRoute>(
          path: '/tasks',
          routes: [
            TypedGoRoute<TaskCreateRoute>(path: 'new'),
            TypedGoRoute<TaskDetailRoute>(path: ':taskId'),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<CalendarBranch>(
      routes: [TypedGoRoute<CalendarRoute>(path: '/calendar')],
    ),
    TypedStatefulShellBranch<KnowledgeBranch>(
      routes: [
        TypedGoRoute<KnowledgeRoute>(
          path: '/knowledge',
          routes: [TypedGoRoute<KnowledgeDetailRoute>(path: 'notes/:noteId')],
        ),
      ],
    ),
    TypedStatefulShellBranch<MoreBranch>(
      routes: [
        TypedGoRoute<MoreRoute>(
          path: '/more',
          routes: [
            TypedGoRoute<ProjectsRoute>(
              path: 'projects',
              routes: [
                TypedGoRoute<ProjectDetailRoute>(
                  path: ':projectId',
                  routes: [
                    TypedGoRoute<ProjectStatisticsRoute>(path: 'statistics'),
                  ],
                ),
              ],
            ),
            TypedGoRoute<RemindersRoute>(path: 'reminders'),
            TypedGoRoute<StatisticsRoute>(path: 'statistics'),
            TypedGoRoute<DocumentsRoute>(
              path: 'documents',
              routes: [TypedGoRoute<DocumentDetailRoute>(path: ':documentId')],
            ),
          ],
        ),
      ],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  static const String $restorationScopeId = 'app_shell_route';

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) => AppShell(navigationShell: navigationShell);
}

class DashboardBranch extends StatefulShellBranchData {
  const DashboardBranch();
}

class TasksBranch extends StatefulShellBranchData {
  const TasksBranch();
}

class CalendarBranch extends StatefulShellBranchData {
  const CalendarBranch();
}

class KnowledgeBranch extends StatefulShellBranchData {
  const KnowledgeBranch();
}

class MoreBranch extends StatefulShellBranchData {
  const MoreBranch();
}

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DashboardPage();
}

class TasksRoute extends GoRouteData with $TasksRoute {
  const TasksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TaskListPage();
}

class TaskDetailRoute extends GoRouteData with $TaskDetailRoute {
  const TaskDetailRoute(this.taskId);
  final int taskId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      TaskDetailPage(taskId: taskId);
}

class TaskCreateRoute extends GoRouteData with $TaskCreateRoute {
  const TaskCreateRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const TaskCreatePage();
}

class CalendarRoute extends GoRouteData with $CalendarRoute {
  const CalendarRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const CalendarPage();
}

class KnowledgeRoute extends GoRouteData with $KnowledgeRoute {
  const KnowledgeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const KnowledgeHomePage();
}

class KnowledgeDetailRoute extends GoRouteData with $KnowledgeDetailRoute {
  const KnowledgeDetailRoute(this.noteId);
  final int noteId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      KnowledgeDetailPage(noteId: noteId);
}

class MoreRoute extends GoRouteData with $MoreRoute {
  const MoreRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) => const MorePage();
}

class ProjectsRoute extends GoRouteData with $ProjectsRoute {
  const ProjectsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ProjectListPage();
}

class ProjectDetailRoute extends GoRouteData with $ProjectDetailRoute {
  const ProjectDetailRoute(this.projectId);
  final int projectId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      ProjectDetailPage(projectId: projectId);
}

class ProjectStatisticsRoute extends GoRouteData with $ProjectStatisticsRoute {
  const ProjectStatisticsRoute(this.projectId);
  final int projectId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      StatisticsPage(projectId: projectId);
}

class RemindersRoute extends GoRouteData with $RemindersRoute {
  const RemindersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const ReminderListPage();
}

class StatisticsRoute extends GoRouteData with $StatisticsRoute {
  const StatisticsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const StatisticsPage();
}

class DocumentsRoute extends GoRouteData with $DocumentsRoute {
  const DocumentsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      const DocumentsPage();
}

class DocumentDetailRoute extends GoRouteData with $DocumentDetailRoute {
  const DocumentDetailRoute(this.documentId);
  final int documentId;

  @override
  Widget build(BuildContext context, GoRouterState state) =>
      DocumentDetailPage(documentId: documentId);
}

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  restorationScopeId: 'app_router',
  routes: $appRoutes,
  debugLogDiagnostics: false,
);
