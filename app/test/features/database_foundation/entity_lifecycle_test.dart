import 'package:anas_life_os/features/database_foundation/domain/entities/entity_lifecycle.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('soft deletes and restores without losing version history', () {
    const active = EntityLifecycle.active();
    final deleted = active.softDelete(DateTime.utc(2026, 7, 30));
    final restored = deleted.restore();

    expect(deleted.isDeleted, isTrue);
    expect(deleted.deletedAt, DateTime.utc(2026, 7, 30));
    expect(deleted.version, 2);
    expect(restored.isDeleted, isFalse);
    expect(restored.deletedAt, isNull);
    expect(restored.version, 3);
  });

  test('repeated lifecycle commands are idempotent', () {
    const active = EntityLifecycle.active();
    final deleted = active.softDelete(DateTime.utc(2026, 7, 30));

    expect(
      identical(deleted, deleted.softDelete(DateTime.utc(2026, 7, 31))),
      isTrue,
    );
    expect(identical(active, active.restore()), isTrue);
  });

  test('rejects contradictory lifecycle state', () {
    expect(
      () => EntityLifecycle(
        version: 0,
        isDeleted: false,
      ),
      throwsArgumentError,
    );
    expect(
      () => EntityLifecycle(
        version: 1,
        isDeleted: true,
      ),
      throwsArgumentError,
    );
  });
}
