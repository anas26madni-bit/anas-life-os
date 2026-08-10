import '../../../../core/errors/result.dart';
import '../entities/project_entity.dart';

abstract interface class ProjectRepository {
  Future<Result<ProjectEntity>> create({
    required String title,
    String? description,
    int? budgetMinor,
    String? currencyCode,
    DateTime? dueAt,
  });
  Future<Result<ProjectEntity>> update(
    int id, {
    required String title,
    String? description,
    int? budgetMinor,
    String? currencyCode,
    DateTime? dueAt,
  });
  Future<Result<ProjectEntity?>> findById(int id);
  Future<Result<List<ProjectEntity>>> list({int limit = 50, int offset = 0});
  Future<Result<void>> archive(int id);
  Future<Result<void>> softDelete(int id);
}
