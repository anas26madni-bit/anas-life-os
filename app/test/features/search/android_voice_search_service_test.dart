import 'package:anas_life_os/features/search/data/services/android_voice_search_service.dart';
import 'package:anas_life_os/features/search/domain/services/voice_search_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('test/voice-search');

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('requests explicit Urdu on-device recognition', () async {
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return call.method == 'isAvailable' ? true : ' نجی تلاش ';
        });
    const service = AndroidVoiceSearchService(channel: channel);

    final result = await service.listen(VoiceSearchLocale.urdu);

    expect(result, isA<VoiceSearchTranscript>());
    expect((result as VoiceSearchTranscript).text, 'نجی تلاش');
    expect(calls, hasLength(2));
    expect(calls.every((call) => call.arguments['locale'] == 'ur-PK'), isTrue);
  });

  test(
    'keeps typed fallback when on-device recognition is unavailable',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => false);
      const service = AndroidVoiceSearchService(channel: channel);

      expect(
        await service.listen(VoiceSearchLocale.english),
        isA<VoiceSearchUnavailable>(),
      );
    },
  );
}
