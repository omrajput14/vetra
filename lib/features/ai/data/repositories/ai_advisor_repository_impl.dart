import '../../domain/repositories/ai_advisor_repository.dart';
import '../api/ai_advisor_api_service.dart';
import '../models/ai_advisor_models.dart';

class AIAdvisorRepositoryImpl implements AIAdvisorRepository {
  final AIAdvisorApiService _apiService;

  AIAdvisorRepositoryImpl({AIAdvisorApiService? apiService})
      : _apiService = apiService ?? AIAdvisorApiService();

  @override
  Future<AIAdvisorSessionModel> createSession({
    required String animalId,
    String? initialMessage,
    String? preferredLanguage,
  }) {
    return _apiService.createSession(
      animalId: animalId,
      initialMessage: initialMessage,
      preferredLanguage: preferredLanguage,
    );
  }

  @override
  Future<AIAdvisorSessionModel> sendMessage({
    required String sessionId,
    required String message,
    String? preferredLanguage,
  }) {
    return _apiService.sendMessage(
      sessionId: sessionId,
      message: message,
      preferredLanguage: preferredLanguage,
    );
  }

  @override
  Future<AIAdvisorSessionModel> getSession(String sessionId) {
    return _apiService.getSession(sessionId);
  }

  @override
  Future<List<AIAdvisorSessionModel>> listSessionsForAnimal(String animalId) {
    return _apiService.listSessionsForAnimal(animalId);
  }
}
