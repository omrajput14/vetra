import '../../data/models/ai_advisor_models.dart';

abstract class AIAdvisorRepository {
  Future<AIAdvisorSessionModel> createSession({
    required String animalId,
    String? initialMessage,
    String? preferredLanguage,
  });

  Future<AIAdvisorSessionModel> sendMessage({
    required String sessionId,
    required String message,
    String? preferredLanguage,
  });

  Future<AIAdvisorSessionModel> getSession(String sessionId);

  Future<List<AIAdvisorSessionModel>> listSessionsForAnimal(String animalId);
}
