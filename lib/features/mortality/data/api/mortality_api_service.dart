import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/mortality_dto.dart';

/// REST API service for interacting with VETRA animal mortality endpoints.
class MortalityApiService {
  final Dio _dio = ApiClient.instance.dio;

  /// Submits an animal death report.
  Future<MortalityReportModel> reportMortality(
    CreateMortalityReportDto dto, {
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        ApiConfig.mortalities,
        data: dto.toJson(),
        options: idempotencyKey != null
            ? Options(headers: {'Idempotency-Key': idempotencyKey})
            : null,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return MortalityReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      return MortalityReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves a mortality report by its UUID.
  Future<MortalityReportModel> getMortalityById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.mortalities}/$id');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return MortalityReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      return MortalityReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves the mortality report for a specific animal.
  Future<MortalityReportModel> getMortalityByAnimalId(String animalId) async {
    try {
      final response = await _dio.get('${ApiConfig.mortalities}/animal/$animalId');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return MortalityReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      return MortalityReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Lists mortality reports submitted by the farmer.
  Future<List<MortalityReportModel>> listFarmerMortalities({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiConfig.mortalities,
        queryParameters: {'page': page, 'size': size},
      );
      final responseData = response.data;
      final dynamic content = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? (responseData['data'] is Map<String, dynamic> && responseData['data'].containsKey('content')
              ? responseData['data']['content']
              : responseData['data'])
          : responseData;

      if (content is List) {
        return content
            .map((item) => MortalityReportModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Fetches disease catalog from registry.
  Future<List<String>> getDiseaseCatalog() async {
    try {
      final response = await _dio.get(ApiConfig.diseaseRegistry);
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        return data
            .map((item) => (item as Map<String, dynamic>)['diseaseName']?.toString() ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
      }
      return _defaultDiseaseList;
    } catch (_) {
      return _defaultDiseaseList;
    }
  }

  static const List<String> _defaultDiseaseList = [
    'Foot and Mouth Disease',
    'Rabies',
    'Brucellosis',
    'Anthrax',
    'Avian Influenza',
    'African Swine Fever',
    'Lumpy Skin Disease',
    'Bovine Mastitis',
  ];

  /// Retrieves pending mortality cases referred to the authenticated veterinarian.
  Future<List<MortalityReportModel>> getPendingMortalityCases({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        "${ApiConfig.mortalities}/pending",
        queryParameters: {"page": page, "size": size},
      );
      final responseData = response.data;
      final dynamic content = (responseData is Map<String, dynamic> && responseData.containsKey("data"))
          ? (responseData["data"] is Map<String, dynamic> && responseData["data"].containsKey("content")
              ? responseData["data"]["content"]
              : responseData["data"])
          : responseData;

      if (content is List) {
        return content
            .map((item) => MortalityReportModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Veterinarian confirms mortality with clinical diagnosis and audit trail.
  Future<MortalityReportModel> confirmMortality(
    String id,
    ConfirmMortalityDto dto, {
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConfig.mortalities}/$id/confirm",
        data: dto.toJson(),
        options: idempotencyKey != null
            ? Options(headers: {"Idempotency-Key": idempotencyKey})
            : null,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
        return MortalityReportModel.fromJson(responseData["data"] as Map<String, dynamic>);
      }
      return MortalityReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Veterinarian rejects mortality report with clinical rationale.
  Future<MortalityReportModel> rejectMortality(
    String id,
    RejectMortalityDto dto, {
    String? idempotencyKey,
  }) async {
    try {
      final response = await _dio.post(
        "${ApiConfig.mortalities}/$id/reject",
        data: dto.toJson(),
        options: idempotencyKey != null
            ? Options(headers: {"Idempotency-Key": idempotencyKey})
            : null,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
        return MortalityReportModel.fromJson(responseData["data"] as Map<String, dynamic>);
      }
      return MortalityReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves full audit history for a mortality report.
  Future<List<MortalityAuditDto>> getMortalityAudits(String id) async {
    try {
      final response = await _dio.get("${ApiConfig.mortalities}/$id/audits");
      final responseData = response.data;
      final dynamic list = (responseData is Map<String, dynamic> && responseData.containsKey("data"))
          ? responseData["data"]
          : responseData;

      if (list is List) {
        return list
            .map((item) => MortalityAuditDto.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
