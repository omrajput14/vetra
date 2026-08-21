import 'package:flutter/foundation.dart';
import '../../data/models/ai_advisor_models.dart';
import '../../data/repositories/ai_advisor_repository_impl.dart';
import '../../domain/repositories/ai_advisor_repository.dart';

class AIAdvisorNotifier extends ChangeNotifier {
  final AIAdvisorRepository _repository;

  AIAdvisorNotifier({AIAdvisorRepository? repository})
      : _repository = repository ?? AIAdvisorRepositoryImpl();

  AIAdvisorSessionModel? _currentSession;
  List<AIAdvisorSessionModel> _pastSessions = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  AIAdvisorSessionModel? get currentSession => _currentSession;
  List<AIAdvisorSessionModel> get pastSessions => _pastSessions;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  String? get errorMessage => _errorMessage;

  List<AIAdvisorMessageModel> get messages => _currentSession?.messages ?? [];
  AIAdvisorAssessmentModel? get assessment => _currentSession?.assessment;
  AIAdvisorSessionStatus? get status => _currentSession?.status;
  AIAdvisorRiskLevel? get riskLevel => _currentSession?.riskLevel;

  void setCurrentSession(AIAdvisorSessionModel session) {
    _currentSession = session;
    _errorMessage = null;
    notifyListeners();
  }

  void clearSession() {
    _currentSession = null;
    _errorMessage = null;
    _isLoading = false;
    _isSending = false;
    notifyListeners();
  }

  Future<bool> startSession(String animalId, {String? initialMessage, String? preferredLanguage}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _repository.createSession(
        animalId: animalId,
        initialMessage: initialMessage,
        preferredLanguage: preferredLanguage,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> loadSession(String sessionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentSession = await _repository.getSession(sessionId);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String text, {String? animalId, String? preferredLanguage}) async {
    if (text.trim().isEmpty) return false;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentSession == null) {
        if (animalId != null && animalId.isNotEmpty) {
          _currentSession = await _repository.createSession(
            animalId: animalId,
            initialMessage: text.trim(),
            preferredLanguage: preferredLanguage,
          );
          return true;
        } else {
          _errorMessage = 'No active animal context';
          return false;
        }
      }

      _currentSession = await _repository.sendMessage(
        sessionId: _currentSession!.id,
        message: text.trim(),
        preferredLanguage: preferredLanguage,
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<void> loadPastSessions(String animalId) async {
    try {
      _pastSessions = await _repository.listSessionsForAnimal(animalId);
      notifyListeners();
    } catch (_) {
      // Ignored for background listing
    }
  }
}

final aiAdvisorNotifier = AIAdvisorNotifier();
