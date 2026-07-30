import 'package:drift/drift.dart';

abstract class BusinessEntityTable extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get uuid => text().withLength(min: 36, max: 36).unique()();

  IntColumn get createdAt => integer()();

  IntColumn get updatedAt => integer()();

  IntColumn get deletedAt => integer().nullable()();

  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  TextColumn get syncStatus =>
      text().withDefault(const Constant('local'))();

  IntColumn get version => integer().withDefault(const Constant(1))();

  TextColumn get createdBy => text().nullable()();

  TextColumn get updatedBy => text().nullable()();

  TextColumn get notes => text().nullable()();
}
