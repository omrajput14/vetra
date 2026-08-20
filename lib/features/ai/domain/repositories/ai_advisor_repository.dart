import '../../data/models/ai_advisor_models.dart';

abstract class AIAdvisorRepository {
  Future<AIAdvisorSessionModel> createSession({
    required String animalId,
    String? initialMessage,
  });

  Future<AIAdvisorSessionModel> sendMessage({
    required String sessionId,
    required String message,
  });

  Future<AIAdvisorSessionModel> getSession(String sessionId);

  Future<List<AIAdvisorSessionModel>> listSessionsForAnimal(String animalId);
}
