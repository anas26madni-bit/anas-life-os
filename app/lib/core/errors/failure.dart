sealed class Failure {
  const Failure({required this.code, required this.safeMessage});

  final String code;
  final String safeMessage;
}

final class InitializationFailure extends Failure {
  const InitializationFailure({
    required super.code,
    required super.safeMessage,
  });
}

final class ValidationFailure extends Failure {
  const ValidationFailure({required super.code, required super.safeMessage});
}
