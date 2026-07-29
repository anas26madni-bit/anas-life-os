import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../startup/foundation_page.dart';

part 'app_router.g.dart';

@TypedGoRoute<FoundationRoute>(path: '/')
class FoundationRoute extends GoRouteData {
  const FoundationRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const FoundationPage();
  }
}

final GoRouter appRouter = GoRouter(
  routes: $appRoutes,
  debugLogDiagnostics: false,
);
