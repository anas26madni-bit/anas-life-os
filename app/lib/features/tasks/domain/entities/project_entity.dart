final class ProjectEntity {
  const ProjectEntity({
    required this.id,
    required this.uuid,
    required this.title,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.version,
    this.description,
    this.budgetMinor,
    this.currencyCode,
    this.dueAt,
  });

  final int id;
  final String uuid;
  final String title;
  final String? description;
  final String status;
  final int? budgetMinor;
  final String? currencyCode;
  final DateTime? dueAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;
  final int version;
}