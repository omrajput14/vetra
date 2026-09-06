import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../storage/secure_storage_service.dart';

/// Supported application locales
class AppLocales {
  static const Locale english = Locale('en');
  static const Locale hindi = Locale('hi');
  static const Locale marathi = Locale('mr');
  static const Locale urdu = Locale('ur');

  static const List<Locale> supported = [english, hindi, marathi, urdu];

  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'mr':
        return 'मराठी (Marathi)';
      case 'ur':
        return 'اردو (Urdu)';
      case 'en':
      default:
        return 'English';
    }
  }

  static String getLanguageNativeName(String languageCode) {
    switch (languageCode) {
      case 'hi':
        return 'हिंदी';
      case 'mr':
        return 'मराठी';
      case 'ur':
        return 'اردو';
      case 'en':
      default:
        return 'English';
    }
  }
}

/// State notifier managing the active UI locale with persistent storage and backend synchronization.
class LocaleNotifier extends StateNotifier<Locale> {
  final SecureStorageService _storageService;

  LocaleNotifier({Locale? initialLocale, SecureStorageService? storageService})
      : _storageService = storageService ?? SecureStorageService.instance,
        super(initialLocale ?? AppLocales.english) {
    if (initialLocale == null) {
      loadSavedLocale();
    }
  }

  /// Loads persisted locale code from secure local storage on app initialization.
  Future<void> loadSavedLocale() async {
    try {
      final savedCode = await _storageService.getPreferredLanguage();
      if (savedCode != null && savedCode.isNotEmpty) {
        if (savedCode == 'hi' || savedCode == 'mr' || savedCode == 'ur' || savedCode == 'en') {
          state = Locale(savedCode);
        }
      }
    } catch (_) {
      // Fallback to default English
      state = AppLocales.english;
    }
  }

  /// Sets active locale, persists to local storage, and syncs with backend profile if authenticated.
  Future<void> setLocale(Locale newLocale) async {
    if (state == newLocale) return;

    state = newLocale;

    try {
      await _storageService.savePreferredLanguage(newLocale.languageCode);

      final token = await _storageService.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Sync to backend user preferences asynchronously
        ApiClient.instance.dio.put(
          '/api/v1/users/preferences/language',
          data: {'language': newLocale.languageCode},
        ).catchError((_) {
          // Non-blocking network sync failure handling
          return null as dynamic;
        });
      }
    } catch (_) {
      // Local state is already updated; ignore persistence errors
    }
  }

  /// Convenience setter by language code ('en', 'hi', 'mr', 'ur')
  Future<void> setLanguageCode(String languageCode) async {
    final validCode = (languageCode == 'hi' || languageCode == 'mr' || languageCode == 'ur') ? languageCode : 'en';
    await setLocale(Locale(validCode));
  }
}

/// Global provider for managing the active app locale.
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
