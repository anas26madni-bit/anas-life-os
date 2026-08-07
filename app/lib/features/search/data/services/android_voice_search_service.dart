import 'package:flutter/services.dart';

import '../../domain/services/voice_search_service.dart';

final class AndroidVoiceSearchService implements VoiceSearchService {
  const AndroidVoiceSearchService({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.anaslifeos.app/on_device_voice_search';
  final MethodChannel _channel;

  @override
  Future<bool> isAvailable(VoiceSearchLocale locale) async =>
      await _channel.invokeMethod<bool>('isAvailable', {
        'locale': _tag(locale),
      }) ??
      false;

  @override
  Future<VoiceSearchResult> listen(VoiceSearchLocale locale) async {
    if (!await isAvailable(locale)) return const VoiceSearchUnavailable();
    try {
      final transcript = await _channel.invokeMethod<String>('listen', {
        'locale': _tag(locale),
      });
      if (transcript == null || transcript.trim().isEmpty) {
        return const VoiceSearchUnavailable();
      }
      return VoiceSearchTranscript(transcript.trim());
    } on PlatformException {
      return const VoiceSearchUnavailable();
    }
  }

  @override
  Future<void> cancel() => _channel.invokeMethod<void>('cancel');

  String _tag(VoiceSearchLocale locale) => switch (locale) {
    VoiceSearchLocale.english => 'en-US',
    VoiceSearchLocale.urdu => 'ur-PK',
  };
}
