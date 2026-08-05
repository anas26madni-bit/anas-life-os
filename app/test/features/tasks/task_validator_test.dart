import 'package:anas_life_os/core/errors/result.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_draft.dart';
import 'package:anas_life_os/features/tasks/domain/entities/task_enums.dart';
import 'package:anas_life_os/features/tasks/domain/services/task_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validator = TaskValidator();

  test('normalizes valid task input and completed progress', () {
    final result = validator.validate(
      const TaskDraft(
        title: '  Review  ',
        status: TaskStatus.completed,
        progress: 12,
      ),
    );
    expect(result, isA<Success<TaskDraft>>());
    final value = (result as Success<TaskDraft>).value;
    expect(value.title, 'Review');
    expect(value.progress, 100);
  });

  test('rejects blank title and invalid temporal range', () {
    expect(
      validator.validate(const TaskDraft(title: ' ')),
      isA<FailureResult<TaskDraft>>(),
    );
    expect(
      validator.validate(
        TaskDraft(
          title: 'Invalid dates',
          startAt: DateTime.utc(2026, 8, 2),
          dueAt: DateTime.utc(2026, 8, 1),
        ),
      ),
      isA<FailureResult<TaskDraft>>(),
    );
  });

  test('rejects mandatory root task', () {
    expect(
      validator.validate(const TaskDraft(title: 'Root', isMandatory: true)),
      isA<FailureResult<TaskDraft>>(),
    );
  });
}
