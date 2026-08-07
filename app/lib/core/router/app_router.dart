import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../features/reminders/presentation/pages/reminder_list_page.dart';
import '../../features/knowledge/presentation/pages/documents_page.dart';
import '../../features/knowledge/presentation/pages/knowledge_home_page.dart';
import '../../features/tasks/presentation/pages/task_list_page.dart';
import '../startup/foundation_page.dart';

part 'app_router.g.dart';

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData with $FoundationRoute {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FoundationPage();
  }
}

@TypedGoRoute<TasksRoute>(path: '/tasks')
class TasksRoute extends GoRouteData with $TasksRoute {
  const TasksRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TaskListPage();
  }
}

@TypedGoRoute<RemindersRoute>(path: '/reminders')
class RemindersRoute extends GoRouteData with $RemindersRoute {
  const RemindersRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ReminderListPage();
  }
}

@TypedGoRoute<KnowledgeRoute>(path: '/knowledge')
class KnowledgeRoute extends GoRouteData with $KnowledgeRoute {
  const KnowledgeRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const KnowledgeHomePage();
  }
}

@TypedGoRoute<DocumentsRoute>(path: '/knowledge/documents')
class DocumentsRoute extends GoRouteData with $DocumentsRoute {
  const DocumentsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DocumentsPage();
  }
}

final GoRouter appRouter = GoRouter(
  routes: $appRoutes,
  debugLogDiagnostics: false,
);
