import 'package:meta/meta.dart';

@immutable
class AiRequest {
  const AiRequest({required this.operation, required this.inputs});

  final String operation;
  final Map<String, Object?> inputs;
}

@immutable
class AiResponse {
  const AiResponse({required this.outputs});

  final Map<String, Object?> outputs;
}

/// Optional, replaceable AI boundary. No provider is installed in Version 1.
abstract interface class AiProvider {
  String get providerId;

  Future<AiResponse> process(AiRequest request);
}
