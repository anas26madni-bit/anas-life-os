enum VoiceSearchLocale { english, urdu }

sealed class VoiceSearchResult {
  const VoiceSearchResult();
}

final class VoiceSearchTranscript extends VoiceSearchResult {
  const VoiceSearchTranscript(this.text);
  final String text;
}

final class VoiceSearchUnavailable extends VoiceSearchResult {
  const VoiceSearchUnavailable();
}

abstract interface class VoiceSearchService {
  Future<bool> isAvailable(VoiceSearchLocale locale);
  Future<VoiceSearchResult> listen(VoiceSearchLocale locale);
  Future<void> cancel();
}
