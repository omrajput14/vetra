import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Operational states of Text-to-Speech playback.
enum TtsState {
  idle,
  playing,
  paused,
  stopped,
}

/// Playback state info emitted to listeners.
class TtsPlaybackState {
  final TtsState state;
  final String? messageId;
  final String? error;

  const TtsPlaybackState({
    required this.state,
    this.messageId,
    this.error,
  });
}

/// Abstract contract for Text-to-Speech service.
abstract class BaseTtsService {
  Future<bool> initialize();
  Future<bool> speak(
    String text, {
    required String languageCode,
    String? messageId,
  });
  Future<void> stop();
  Future<void> pause();
  Future<void> resume();
  bool get isPlaying;
  String? get currentlySpeakingMessageId;
  TtsState get state;
  Stream<TtsPlaybackState> get stateStream;
}

/// Production Text-to-Speech service supporting Marathi (mr-IN), Hindi (hi-IN), and English (en-IN).
class TtsService implements BaseTtsService {
  static final TtsService instance = TtsService._internal();

  TtsService._internal({FlutterTts? flutterTts})
      : _flutterTts = flutterTts ?? FlutterTts() {
    _initHandlers();
  }

  factory TtsService({FlutterTts? flutterTts}) {
    if (flutterTts != null) {
      return TtsService._internal(flutterTts: flutterTts);
    }
    return instance;
  }

  final FlutterTts _flutterTts;
  bool _isInitialized = false;
  TtsState _state = TtsState.idle;
  String? _currentMessageId;

  final StreamController<TtsPlaybackState> _stateController =
      StreamController<TtsPlaybackState>.broadcast();

  @override
  TtsState get state => _state;

  @override
  bool get isPlaying => _state == TtsState.playing;

  @override
  String? get currentlySpeakingMessageId => _currentMessageId;

  @override
  Stream<TtsPlaybackState> get stateStream => _stateController.stream;

  /// Maps a 2-letter language code to standard Indian BCP-47 locale tags.
  static String mapLocale(String languageCode) {
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

  void _initHandlers() {
    _flutterTts.setStartHandler(() {
      _state = TtsState.playing;
      _emitState();
    });

    _flutterTts.setCompletionHandler(() {
      _state = TtsState.idle;
      _currentMessageId = null;
      _emitState();
    });

    _flutterTts.setCancelHandler(() {
      _state = TtsState.stopped;
      _currentMessageId = null;
      _emitState();
    });

    _flutterTts.setPauseHandler(() {
      _state = TtsState.paused;
      _emitState();
    });

    _flutterTts.setContinueHandler(() {
      _state = TtsState.playing;
      _emitState();
    });

    _flutterTts.setErrorHandler((dynamic msg) {
      debugPrint('[TtsService] Error handler: $msg');
      _state = TtsState.idle;
      final errorMsg = msg?.toString() ?? 'TTS playback error';
      _stateController.add(
        TtsPlaybackState(
          state: TtsState.idle,
          messageId: _currentMessageId,
          error: errorMsg,
        ),
      );
      _currentMessageId = null;
    });
  }

  void _emitState() {
    _stateController.add(
      TtsPlaybackState(
        state: _state,
        messageId: _currentMessageId,
      ),
    );
  }

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    try {
      await _flutterTts.awaitSpeakCompletion(true);
      await _flutterTts.setSpeechRate(0.48); // Natural, clear pacing
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
      return true;
    } catch (e) {
      debugPrint('[TtsService] Initialization error: $e');
      return false;
    }
  }

  /// Cleans markdown and formatting symbols from text before speech synthesis.
  static String cleanTextForSpeech(String rawText) {
    var cleaned = rawText;
    // Remove markdown bold / italic formatting
    cleaned = cleaned.replaceAll(RegExp(r'\*\*|\*|__|_'), '');
    // Remove markdown header indicators (#, ##, etc.)
    cleaned = cleaned.replaceAll(RegExp(r'^#+\s*', multiLine: true), '');
    // Remove bullet points and dashes
    cleaned = cleaned.replaceAll(RegExp(r'^\s*[-•*]\s*', multiLine: true), '');
    // Remove URLs
    cleaned = cleaned.replaceAll(RegExp(r'https?:\/\/[^\s]+'), '');
    // Normalize repeated whitespace
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned;
  }

  @override
  Future<bool> speak(
    String text, {
    required String languageCode,
    String? messageId,
  }) async {
    final cleaned = cleanTextForSpeech(text);
    if (cleaned.isEmpty) return false;

    await initialize();

    // Stop any existing speech before starting a new one
    if (_state == TtsState.playing) {
      await stop();
    }

    _currentMessageId = messageId;
    final primaryLocale = mapLocale(languageCode);

    try {
      // Configure locale with fallback
      final isAvailable = await _flutterTts.isLanguageAvailable(primaryLocale);
      if (isAvailable == true || isAvailable == 1) {
        await _flutterTts.setLanguage(primaryLocale);
      } else {
        // Fallback checks
        final fallbackLocale = languageCode.toLowerCase() == 'mr'
            ? 'hi-IN'
            : (languageCode.toLowerCase() == 'hi' ? 'hi-IN' : 'en-IN');
        debugPrint('[TtsService] Primary locale $primaryLocale not found, falling back to $fallbackLocale');
        await _flutterTts.setLanguage(fallbackLocale);
      }

      _state = TtsState.playing;
      _emitState();

      final result = await _flutterTts.speak(cleaned);
      return result == 1 || result == true;
    } catch (e) {
      debugPrint('[TtsService] Speak error: $e');
      _state = TtsState.idle;
      _currentMessageId = null;
      _emitState();
      return false;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (e) {
      debugPrint('[TtsService] Stop error: $e');
    } finally {
      _state = TtsState.stopped;
      _currentMessageId = null;
      _emitState();
      _state = TtsState.idle;
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (e) {
      debugPrint('[TtsService] Pause error: $e');
    }
  }

  @override
  Future<void> resume() async {
    try {
      _state = TtsState.playing;
      _emitState();
    } catch (e) {
      debugPrint('[TtsService] Resume error: $e');
    }
  }
}
