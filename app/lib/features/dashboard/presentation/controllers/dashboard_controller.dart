import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/dashboard_models.dart';

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardState>(
      DashboardController.new,
    );

final class DashboardState {
  const DashboardState({required this.snapshot, required this.preferences});
  final DashboardSnapshot snapshot;
  final List<DashboardWidgetPreference> preferences;
}

class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final repository = await ref.watch(dashboardRepositoryProvider.future);
    return DashboardState(
      snapshot: _unwrap(await repository.loadSnapshot(DateTime.now())),
      preferences: _unwrap(await repository.loadPreferences()),
    );
  }

  Future<void> toggle(DashboardWidgetKind kind) => _update((items) {
    return items
        .map(
          (item) => item.kind == kind
              ? item.copyWith(visible: !item.visible)
              : item,
        )
        .toList(growable: false);
  });

  Future<void> resize(
    DashboardWidgetKind kind,
    DashboardWidgetSize size,
  ) => _update(
    (items) => items
        .map((item) => item.kind == kind ? item.copyWith(size: size) : item)
        .toList(growable: false),
  );

  Future<void> move(DashboardWidgetKind kind, int delta) => _update((items) {
    final mutable = [...items];
    final current = mutable.indexWhere((item) => item.kind == kind);
    final target = (current + delta).clamp(0, mutable.length - 1);
    if (current >= 0 && current != target) {
      final item = mutable.removeAt(current);
      mutable.insert(target, item);
    }
    return mutable;
  });

  Future<void> reset() async {
    final repository = await ref.read(dashboardRepositoryProvider.future);
    final current = state.requireValue;
    state = AsyncData(
      DashboardState(
        snapshot: current.snapshot,
        preferences: _unwrap(await repository.resetPreferences()),
      ),
    );
  }

  Future<void> refresh() async => state = await AsyncValue.guard(build);

  Future<void> _update(
    List<DashboardWidgetPreference> Function(
      List<DashboardWidgetPreference> items,
    ) transform,
  ) async {
    final repository = await ref.read(dashboardRepositoryProvider.future);
    final current = state.requireValue;
    final next = transform(current.preferences)
        .indexed
        .map((entry) => entry.$2.copyWith(sortOrder: entry.$1))
        .toList(growable: false);
    _unwrap(await repository.savePreferences(next));
    state = AsyncData(
      DashboardState(snapshot: current.snapshot, preferences: next),
    );
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw StateError(failure.safeMessage),
  };
}
