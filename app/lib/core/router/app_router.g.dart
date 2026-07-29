// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

List<RouteBase> get $appRoutes => [$foundationRoute];

RouteBase get $foundationRoute => GoRouteData.$route(
      path: '/',
      factory: $FoundationRouteExtension._fromState,
    );

extension $FoundationRouteExtension on FoundationRoute {
  static FoundationRoute _fromState(GoRouterState state) {
    return const FoundationRoute();
  }

  String get location => GoRouteData.$location('/');

  void go(BuildContext context) => context.go(location);

  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  void replace(BuildContext context) => context.replace(location);
}
