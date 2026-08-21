import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/services/speech_service.dart';

void main() {
  group('SpeechService Language Mapping Tests', () {
    test('Correctly maps Marathi language code to BCP-47 locale ID', () {
      expect(SpeechService.mapLocaleId('mr'), equals('mr_IN'));
      expect(SpeechService.mapLocaleId('MR'), equals('mr_IN'));
      expect(SpeechService.mapLocaleIdHyphenated('mr'), equals('mr-IN'));
    });

    test('Correctly maps Hindi language code to BCP-47 locale ID', () {
      expect(SpeechService.mapLocaleId('hi'), equals('hi_IN'));
      expect(SpeechService.mapLocaleId('HI'), equals('hi_IN'));
      expect(SpeechService.mapLocaleIdHyphenated('hi'), equals('hi-IN'));
    });

    test('Correctly maps English and fallback language codes to BCP-47 locale ID', () {
      expect(SpeechService.mapLocaleId('en'), equals('en_IN'));
      expect(SpeechService.mapLocaleId('gu'), equals('en_IN'));
      expect(SpeechService.mapLocaleId(''), equals('en_IN'));
      expect(SpeechService.mapLocaleIdHyphenated('en'), equals('en-IN'));
    });
  });

  group('VoiceState Enum and Contract Tests', () {
    test('Initializes with default idle state', () {
      final service = SpeechService.instance;
      expect(service.state, isIn([VoiceState.idle, VoiceState.unavailable]));
    });

    test('Enum has all defined voice states', () {
      expect(VoiceState.values, contains(VoiceState.idle));
      expect(VoiceState.values, contains(VoiceState.initializing));
      expect(VoiceState.values, contains(VoiceState.listening));
      expect(VoiceState.values, contains(VoiceState.processing));
      expect(VoiceState.values, contains(VoiceState.error));
      expect(VoiceState.values, contains(VoiceState.unavailable));
    });
  });
}
