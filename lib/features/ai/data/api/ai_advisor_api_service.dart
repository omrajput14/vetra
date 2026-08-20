import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/ai_advisor_models.dart';

class AIAdvisorApiService {
  final Dio _dio = ApiClient.instance.dio;

  /// Initializes a new AI Veterinary Advisor session for an animal.
  Future<AIAdvisorSessionModel> createSession({
    required String animalId,
    String? initialMessage,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/animals/$animalId/ai/advisor/sessions',
        data: initialMessage != null && initialMessage.trim().isNotEmpty
            ? {'initialMessage': initialMessage.trim()}
            : null,
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return AIAdvisorSessionModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected server response format');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to initialize AI Advisor session: ${e.toString()}');
    }
  }

  /// Sends an owner message to an active advisor session and returns the updated session.
  Future<AIAdvisorSessionModel> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/ai/advisor/sessions/$sessionId/messages',
        data: {'message': message.trim()},
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return AIAdvisorSessionModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected server response format');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to send message to AI Advisor: ${e.toString()}');
    }
  }

  /// Retrieves an existing advisor session by ID.
  Future<AIAdvisorSessionModel> getSession(String sessionId) async {
    try {
      final response = await _dio.get('/api/v1/ai/advisor/sessions/$sessionId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return AIAdvisorSessionModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected server response format');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to fetch AI Advisor session: ${e.toString()}');
    }
  }

  /// Lists past advisor sessions for an animal.
  Future<List<AIAdvisorSessionModel>> listSessionsForAnimal(String animalId) async {
    try {
      final response = await _dio.get('/api/v1/animals/$animalId/ai/advisor/sessions');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        final data = responseData['data'];
        if (data is Map<String, dynamic> && data.containsKey('content')) {
          final list = data['content'] as List<dynamic>;
          return list.map((e) => AIAdvisorSessionModel.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to list AI Advisor sessions: ${e.toString()}');
    }
  }
}
