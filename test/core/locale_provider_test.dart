import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/core/storage/secure_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocaleProvider Tests', () {
    test('Defaults to English locale when no saved preference exists', () {
      final notifier = LocaleNotifier();
      expect(notifier.state, equals(const Locale('en')));
      expect(AppLocales.getLanguageName('en'), equals('English'));
      expect(AppLocales.getLanguageNativeName('en'), equals('English'));
    });

    test('Correctly identifies Marathi and Hindi native names', () {
      expect(AppLocales.getLanguageName('mr'), equals('मराठी (Marathi)'));
      expect(AppLocales.getLanguageNativeName('mr'), equals('मराठी'));
      expect(AppLocales.getLanguageName('hi'), equals('हिंदी (Hindi)'));
      expect(AppLocales.getLanguageNativeName('hi'), equals('हिंदी'));
    });

    test('Switches locale to Marathi and Hindi dynamically', () async {
      final notifier = LocaleNotifier();
      await notifier.setLanguageCode('mr');
      expect(notifier.state, equals(const Locale('mr')));

      await notifier.setLanguageCode('hi');
      expect(notifier.state, equals(const Locale('hi')));

      await notifier.setLanguageCode('en');
      expect(notifier.state, equals(const Locale('en')));
    });

    test('Falls back to English for unknown language code', () async {
      final notifier = LocaleNotifier();
      await notifier.setLanguageCode('invalid_code');
      expect(notifier.state, equals(const Locale('en')));
    });
  });
}
