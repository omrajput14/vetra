import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Operational states of the SpeechService.
enum VoiceState {
  idle,
  initializing,
  listening,
  processing,
  error,
  unavailable,
}

/// Abstract contract for voice speech recognition service.
abstract class BaseSpeechService {
  Future<bool> initialize();
  Future<bool> startListening({
    required String languageCode,
    required void Function(String text) onResult,
    void Function(VoiceState state)? onStateChanged,
    void Function(String error)? onError,
  });
  Future<void> stopListening();
  Future<void> cancelListening();
  bool get isListening;
  VoiceState get state;
}

/// Production Speech-to-Text service supporting Marathi, Hindi, and English voice input.
class SpeechService implements BaseSpeechService {
  static final SpeechService instance = SpeechService._internal();

  SpeechService._internal({SpeechToText? speechToText})
      : _speechToText = speechToText ?? SpeechToText();

  factory SpeechService({SpeechToText? speechToText}) {
    if (speechToText != null) {
      return SpeechService._internal(speechToText: speechToText);
    }
    return instance;
  }

  final SpeechToText _speechToText;
  bool _isInitialized = false;
  VoiceState _state = VoiceState.idle;

  @override
  VoiceState get state => _state;

  @override
  bool get isListening => _speechToText.isListening || _state == VoiceState.listening;

  /// Maps a 2-letter app language code ('mr', 'hi', 'en') to a speech recognition BCP-47 locale ID.
  static String mapLocaleId(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'mr':
        return 'mr_IN';
      case 'hi':
        return 'hi_IN';
      case 'en':
      default:
        return 'en_IN';
    }
  }

  /// Maps a 2-letter language code to standard hyphenated format ('mr-IN', 'hi-IN', 'en-IN').
  static String mapLocaleIdHyphenated(String languageCode) {
    switch (languageCode.toLowerCase()) {
      case 'mr':
        return 'mr-IN';
      case 'hi':
        return 'hi-IN';
      case 'en':
      default:
        return 'en-IN';
    }
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    _state = VoiceState.initializing;
    try {
      _isInitialized = await _speechToText.initialize(
        onError: (SpeechRecognitionError error) {
          debugPrint('[SpeechService] Recognition error: ${error.errorMsg}');
          _state = VoiceState.error;
        },
        onStatus: (String status) {
          debugPrint('[SpeechService] Status change: $status');
          if (status == 'listening') {
            _state = VoiceState.listening;
          } else if (status == 'notListening' || status == 'done') {
            if (_state == VoiceState.listening) {
              _state = VoiceState.idle;
            }
          }
        },
      );
      _state = _isInitialized ? VoiceState.idle : VoiceState.unavailable;
      return _isInitialized;
    } catch (e) {
      debugPrint('[SpeechService] Initialization exception: $e');
      _state = VoiceState.unavailable;
      _isInitialized = false;
      return false;
    }
  }

  @override
  Future<bool> startListening({
    required String languageCode,
    required void Function(String text) onResult,
    void Function(VoiceState state)? onStateChanged,
    void Function(String error)? onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        _state = VoiceState.unavailable;
        onStateChanged?.call(_state);
        onError?.call('Speech recognition is not available on this device');
        return false;
      }
    }

    if (_speechToText.isListening) {
      await stopListening();
    }

    final localeId = mapLocaleId(languageCode);
    _state = VoiceState.listening;
    onStateChanged?.call(_state);

    try {
      final listenOptions = SpeechListenOptions(
        localeId: localeId,
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      );

      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          if (result.recognizedWords.isNotEmpty) {
            onResult(result.recognizedWords);
          }
          if (result.finalResult) {
            _state = VoiceState.idle;
            onStateChanged?.call(_state);
          }
        },
        listenOptions: listenOptions,
      );
      return true;
    } catch (e) {
      debugPrint('[SpeechService] Listen error: $e');
      _state = VoiceState.error;
      onStateChanged?.call(_state);
      onError?.call(e.toString());
      return false;
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
    } catch (e) {
      debugPrint('[SpeechService] Stop error: $e');
    } finally {
      _state = VoiceState.idle;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
    } catch (e) {
      debugPrint('[SpeechService] Cancel error: $e');
    } finally {
      _state = VoiceState.idle;
    }
  }
}
