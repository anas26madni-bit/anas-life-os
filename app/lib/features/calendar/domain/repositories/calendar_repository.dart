import '../../../../core/errors/result.dart';
import '../entities/calendar_models.dart';

abstract interface class CalendarRepository {
  Future<Result<CalendarEvent>> create(CalendarEventDraft draft);
  Future<Result<CalendarEvent>> update(int id, CalendarEventDraft draft);
  Future<Result<void>> softDelete(int id);
  Future<Result<List<CalendarItem>>> listRange(DateTime start, DateTime end);
}
