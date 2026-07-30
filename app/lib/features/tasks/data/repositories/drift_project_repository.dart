import 'package:drift/drift.dart';

import '../../../../core/database/uuid_generator.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../database_foundation/data/database/app_database.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/project_repository.dart';

final class DriftProjectRepository implements ProjectRepository {
  DriftProjectRepository(
    this._database, {
    DateTime Function()? clock,
    String Function()? uuidFactory,
  }) : _clock = clock ?? DateTime.now,
       _uuidFactory = uuidFactory ?? UuidGenerator().generate;

  final AppDatabase _database;
  final DateTime Function() _clock;
  final String Function() _uuidFactory;

  @override
  Future<Result<ProjectEntity>> create({
    required String title,
    String? description,
    int? budgetMinor,
    String? currencyCode,
    DateTime? dueAt,
  }) async {
    final normalizedTitle = title.trim();
    final normalizedCurrency = currencyCode?.trim().toUpperCase();
    if (normalizedTitle.isEmpty ||
        normalizedTitle.runes.length > 300 ||
        (budgetMinor ?? 0) < 0 ||
        (normalizedCurrency != null && normalizedCurrency.length != 3)) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_project',
          safeMessage: 'The project details are invalid.',
        ),
      );
    }
    try {
      final now = _clock().toUtc();
      final id = await _database
          .into(_database.projects)
          .insert(
            ProjectsCompanion.insert(
              uuid: _uuidFactory(),
              title: normalizedTitle,
              createdAt: now.microsecondsSinceEpoch,
              updatedAt: now.microsecondsSinceEpoch,
              description: Value(description?.trim()),
              budgetMinor: Value(budgetMinor),
              currencyCode: Value(normalizedCurrency),
              dueAt: Value(dueAt?.toUtc().microsecondsSinceEpoch),
            ),
          );
      final row = await (_database.select(
        _database.projects,
      )..where((item) => item.id.equals(id))).getSingle();
      return Success(_map(row));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'project_create_failed',
          safeMessage: 'The project could not be created safely.',
        ),
      );
    }
  }

  @override
  Future<Result<List<ProjectEntity>>> list({
    int limit = 50,
    int offset = 0,
  }) async {
    if (limit < 1 || limit > 200 || offset < 0) {
      return const FailureResult(
        ValidationFailure(
          code: 'invalid_project_page',
          safeMessage: 'The requested project page is invalid.',
        ),
      );
    }
    try {
      final query = _database.select(_database.projects)
        ..where((row) => row.isDeleted.equals(false))
        ..orderBy([(row) => OrderingTerm.desc(row.updatedAt)])
        ..limit(limit, offset: offset);
      return Success((await query.get()).map(_map).toList(growable: false));
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'project_list_failed',
          safeMessage: 'Projects could not be loaded.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> archive(int id) async {
    try {
      final updated =
          await (_database.update(_database.projects)..where(
                (row) => row.id.equals(id) & row.isDeleted.equals(false),
              ))
              .write(
                ProjectsCompanion(
                  status: const Value('archived'),
                  updatedAt: Value(_clock().toUtc().microsecondsSinceEpoch),
                ),
              );
      if (updated != 1) throw StateError('Project not found.');
      return const Success(null);
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'project_archive_rejected',
          safeMessage: error.message,
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'project_archive_failed',
          safeMessage: 'The project could not be archived safely.',
        ),
      );
    }
  }

  @override
  Future<Result<void>> softDelete(int id) async {
    try {
      return await _database.transaction(() async {
        final activeTasks =
            await (_database.select(_database.tasks)..where(
                  (row) =>
                      row.projectId.equals(id) & row.isDeleted.equals(false),
                ))
                .get();
        if (activeTasks.isNotEmpty)
          throw StateError(
            'Move, archive, or delete active project tasks first.',
          );
        final now = _clock().toUtc().microsecondsSinceEpoch;
        final updated =
            await (_database.update(_database.projects)..where(
                  (row) => row.id.equals(id) & row.isDeleted.equals(false),
                ))
                .write(
                  ProjectsCompanion(
                    isDeleted: const Value(true),
                    deletedAt: Value(now),
                    updatedAt: Value(now),
                    status: const Value('deleted'),
                  ),
                );
        if (updated != 1) throw StateError('Project not found.');
        return const Success(null);
      });
    } on StateError catch (error) {
      return FailureResult(
        ValidationFailure(
          code: 'project_delete_rejected',
          safeMessage: error.message,
        ),
      );
    } on Object {
      return const FailureResult(
        DatabaseFailure(
          code: 'project_delete_failed',
          safeMessage: 'The project could not be deleted safely.',
        ),
      );
    }
  }

  ProjectEntity _map(ProjectRow row) => ProjectEntity(
    id: row.id,
    uuid: row.uuid,
    title: row.title,
    description: row.description,
    status: row.status,
    budgetMinor: row.budgetMinor,
    currencyCode: row.currencyCode,
    dueAt: _date(row.dueAt),
    createdAt: _date(row.createdAt)!,
    updatedAt: _date(row.updatedAt)!,
    isDeleted: row.isDeleted,
    version: row.version,
  );

  DateTime? _date(int? value) => value == null
      ? null
      : DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true);
}
