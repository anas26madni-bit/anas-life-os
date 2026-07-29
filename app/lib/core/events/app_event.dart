import 'package:meta/meta.dart';

@immutable
abstract interface class AppEvent {
  String get name;
  String get entityType;
  String? get entityId;
  DateTime get occurredAt;
}

abstract interface class AppEventPublisher {
  Future<void> publish(AppEvent event);
}

abstract interface class AppEventSubscriber {
  Stream<AppEvent> get events;
}
