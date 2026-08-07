import '../../../../core/errors/result.dart';
import '../entities/dashboard_models.dart';

abstract interface class DashboardRepository {
  Future<Result<DashboardSnapshot>> loadSnapshot(DateTime now);
  Future<Result<List<DashboardWidgetPreference>>> loadPreferences();
  Future<Result<void>> savePreferences(
    List<DashboardWidgetPreference> preferences,
  );
  Future<Result<List<DashboardWidgetPreference>>> resetPreferences();
}
