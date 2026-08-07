import 'package:drift/drift.dart';

import '../../domain/entities/dashboard_models.dart';

@DataClassName('DashboardWidgetPreferenceRow')
@TableIndex(
  name: 'idx_dashboard_widget_kind',
  columns: {#kind},
  unique: true,
)
class DashboardWidgetPreferences extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<DashboardWidgetKind>()();
  BoolColumn get visible => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer()();
  TextColumn get size => textEnum<DashboardWidgetSize>()();
  IntColumn get updatedAt => integer()();
}
