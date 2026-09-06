import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/services/tts_service.dart';
import 'package:vetra/core/services/speech_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TtsService Locale & Text Formatting Tests', () {
    test('Maps app languages to standard Indian BCP-47 locale tags', () {
      expect(TtsService.mapLocale('en'), 'en-IN');
      expect(TtsService.mapLocale('EN'), 'en-IN');
      expect(TtsService.mapLocale('hi'), 'hi-IN');
      expect(TtsService.mapLocale('HI'), 'hi-IN');
      expect(TtsService.mapLocale('mr'), 'mr-IN');
      expect(TtsService.mapLocale('MR'), 'mr-IN');
      expect(TtsService.mapLocale('unknown'), 'en-IN');
    });

    test('SpeechService maps app languages to STT locale IDs', () {
      expect(SpeechService.mapLocaleId('en'), 'en_IN');
      expect(SpeechService.mapLocaleId('hi'), 'hi_IN');
      expect(SpeechService.mapLocaleId('mr'), 'mr_IN');

      expect(SpeechService.mapLocaleIdHyphenated('en'), 'en-IN');
      expect(SpeechService.mapLocaleIdHyphenated('hi'), 'hi-IN');
      expect(SpeechService.mapLocaleIdHyphenated('mr'), 'mr-IN');
    });

    test('cleanTextForSpeech strips markdown asterisks, headers, bullets, and URLs', () {
      const rawMarkdown = '''
# Clinical Advisory
**Primary Condition:** Bovine Respiratory Disease (BRD)
* High fever (104.5°F)
* Nasal discharge and coughing
Please visit https://vetra.app/info for details.
''';
      final cleaned = TtsService.cleanTextForSpeech(rawMarkdown);

      expect(cleaned.contains('#'), isFalse);
      expect(cleaned.contains('**'), isFalse);
      expect(cleaned.contains('*'), isFalse);
      expect(cleaned.contains('https://'), isFalse);
      expect(cleaned.contains('Clinical Advisory'), isTrue);
      expect(cleaned.contains('Primary Condition: Bovine Respiratory Disease (BRD)'), isTrue);
      expect(cleaned.contains('High fever (104.5°F)'), isTrue);
      expect(cleaned.contains('Nasal discharge and coughing'), isTrue);
    });

    test('cleanTextForSpeech handles empty or whitespace-only input safely', () {
      expect(TtsService.cleanTextForSpeech(''), '');
      expect(TtsService.cleanTextForSpeech('   \n  \t  '), '');
    });

    test('TtsState initial state is idle and currentlySpeakingMessageId is null', () {
      final ttsService = TtsService.instance;
      expect(ttsService.state, TtsState.idle);
      expect(ttsService.isPlaying, isFalse);
      expect(ttsService.currentlySpeakingMessageId, isNull);
    });

    test('cleanTextForSpeech preserves Marathi and Hindi characters cleanly', () {
      const marathiText = '''
**प्राथमिक तपासणी:**
* गायीला ताप आहे
* चारा खात नाही
तातडीने पशुवैद्यकीय डॉक्टरांशी संपर्क साधा.
''';
      final cleanedMarathi = TtsService.cleanTextForSpeech(marathiText);
      expect(cleanedMarathi.contains('*'), isFalse);
      expect(cleanedMarathi.contains('**'), isFalse);
      expect(cleanedMarathi.contains('गायीला ताप आहे'), isTrue);
      expect(cleanedMarathi.contains('तातडीने पशुवैद्यकीय'), isTrue);

      const hindiText = '''
## प्राथमिक परामर्श
- पशु को बुखार है और आहार नहीं ले रहा है
- तुरंत पशु चिकित्सक को दिखाएं
''';
      final cleanedHindi = TtsService.cleanTextForSpeech(hindiText);
      expect(cleanedHindi.contains('##'), isFalse);
      expect(cleanedHindi.contains('-'), isFalse);
      expect(cleanedHindi.contains('पशु को बुखार है'), isTrue);
      expect(cleanedHindi.contains('तुरंत पशु चिकित्सक'), isTrue);
    });
  });
}
