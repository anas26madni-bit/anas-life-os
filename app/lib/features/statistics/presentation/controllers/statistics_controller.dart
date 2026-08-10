import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/result.dart';
import '../../../../core/providers/infrastructure_providers.dart';
import '../../domain/entities/statistics_models.dart';

final class StatisticsRequest {
  const StatisticsRequest({
    required this.selection,
    required this.granularity,
    this.projectId,
  });

  final DateTime selection;
  final StatisticsGranularity granularity;
  final int? projectId;

  @override
  bool operator ==(Object other) =>
      other is StatisticsRequest &&
      other.selection == selection &&
      other.granularity == granularity &&
      other.projectId == projectId;

  @override
  int get hashCode => Object.hash(selection, granularity, projectId);
}

final statisticsReportProvider = FutureProvider.autoDispose
    .family<StatisticsReport, StatisticsRequest>((ref, request) async {
      final repository = await ref.watch(statisticsRepositoryProvider.future);
      final result = await repository.loadReport(
        selection: request.selection,
        granularity: request.granularity,
        projectId: request.projectId,
      );
      return switch (result) {
        Success<StatisticsReport>(:final value) => value,
        FailureResult<StatisticsReport>(:final failure) =>
          throw StateError(failure.safeMessage),
      };
    });
