import '../../../../core/errors/result.dart';
import '../entities/statistics_models.dart';

abstract interface class StatisticsRepository {
  Future<Result<StatisticsReport>> loadReport({
    required DateTime selection,
    required StatisticsGranularity granularity,
    int? projectId,
  });

  Future<Result<void>> rebuildRange(StatisticsRange range, {int? projectId});
}
