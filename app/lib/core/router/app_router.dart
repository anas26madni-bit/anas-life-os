import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

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

final GoRouter appRouter = GoRouter(
  routes: $appRoutes,
  debugLogDiagnostics: false,
);