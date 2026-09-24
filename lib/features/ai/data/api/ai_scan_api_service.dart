import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/ai_scan_model.dart';

class AIScanApiService {
  final Dio _dio = ApiClient.instance.dio;

  /// Submits an image scan to the backend AI diagnosis API.
  Future<AIScanModel> createScan({
    required String animalId,
    required String imagePath,
    String? idempotencyKey,
  }) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw Exception('Selected image file does not exist locally.');
      }

      final bytes = await file.readAsBytes();
      final base64Image = base64Encode(bytes);
      final dataUri = 'data:image/jpeg;base64,$base64Image';

      final response = await _dio.post(
        '/api/v1/ai/scans',
        data: {
          'animalId': animalId,
          'imageUrl': dataUri,
        },
        options: Options(
          sendTimeout: const Duration(seconds: 35),
          receiveTimeout: const Duration(seconds: 35),
          headers: idempotencyKey != null ? {'Idempotency-Key': idempotencyKey} : null,
        ),
      );

      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return AIScanModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected server response format');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to submit AI scan: ${e.toString()}');
    }
  }

  /// GET /ai/scans: the signed-in user's scans.
  Future<List<AIScanModel>> listScans() async {
    try {
      final response = await _dio.get('/api/v1/ai/scans');
      final list = response.data['data'] as List<dynamic>? ?? const [];
      return list.map((e) => AIScanModel.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Fetches an existing AI scan by ID.
  Future<AIScanModel> getScanById(String scanId) async {
    try {
      final response = await _dio.get('/api/v1/ai/scans/$scanId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return AIScanModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      throw Exception('Unexpected server response format');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    } catch (e) {
      if (e is NetworkException) rethrow;
      throw Exception('Failed to fetch AI scan details: ${e.toString()}');
    }
  }
}
