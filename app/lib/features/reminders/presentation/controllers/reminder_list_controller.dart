import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/reminder_draft.dart';
import '../../domain/entities/reminder_entity.dart';
import '../../domain/usecases/reminder_use_cases.dart';

final reminderUseCasesProvider = FutureProvider<ReminderUseCases>((ref) async {
  final repository = await ref.watch(reminderRepositoryProvider.future);
  final scheduler = ref.watch(reminderSchedulerProvider);
  return ReminderUseCases(repository, scheduler);
});

final reminderListControllerProvider =
    AsyncNotifierProvider<ReminderListController, List<ReminderEntity>>(
      ReminderListController.new,
    );

class ReminderListController extends AsyncNotifier<List<ReminderEntity>> {
  @override
  Future<List<ReminderEntity>> build() async {
    final useCases = await ref.watch(reminderUseCasesProvider.future);
    _unwrap(await useCases.synchronizePlatformEvents());
    return _unwrap(await useCases.list());
  }

  Future<void> create(ReminderDraft draft) async {
    await _mutate((useCases) => useCases.create(draft));
  }

  Future<void> setEnabled(int id, bool enabled) async {
    await _mutate((useCases) => useCases.setEnabled(id, enabled));
  }

  Future<void> delete(int id) async {
    await _mutate((useCases) => useCases.delete(id));
  }

  Future<void> refresh() async {
    state = const AsyncLoading<List<ReminderEntity>>();
    state = await AsyncValue.guard(build);
  }

  Future<void> _mutate(
    Future<Result<ReminderEntity>> Function(ReminderUseCases useCases) operation,
  ) async {
    state = const AsyncLoading<List<ReminderEntity>>();
    state = await AsyncValue.guard(() async {
      final useCases = await ref.read(reminderUseCasesProvider.future);
      _unwrap(await operation(useCases));
      return _unwrap(await useCases.list());
    });
  }

  T _unwrap<T>(Result<T> result) => switch (result) {
    Success<T>(:final value) => value,
    FailureResult<T>(:final failure) => throw ReminderOperationException(
      failure.safeMessage,
    ),
  };
}

final class ReminderOperationException implements Exception {
  const ReminderOperationException(this.message);

  final String message;

  @override
  String toString() => message;
}
