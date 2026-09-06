import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';
import '../models/disease_report_dto.dart';
import '../models/outbreak_dto.dart';


/// REST API service for interacting with the VETRA Disease Surveillance backend.
class DiseaseApiService {
  final Dio _dio = ApiClient.instance.dio;

  /// Submits a new disease surveillance report.
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto, {String? idempotencyKey}) async {
    try {
      final response = await _dio.post(
        ApiConfig.diseaseReports,
        data: dto.toJson(),
        options: idempotencyKey != null ? Options(headers: {'Idempotency-Key': idempotencyKey}) : null,
      );
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return DiseaseReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      return DiseaseReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves a specific disease report by UUID.
  Future<DiseaseReportModel> getDiseaseReport(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.diseaseReports}/$id');
      final responseData = response.data;
      if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
        return DiseaseReportModel.fromJson(responseData['data'] as Map<String, dynamic>);
      }
      return DiseaseReportModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Lists disease reports for the authenticated user with pagination.
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20}) async {
    try {
      final response = await _dio.get(
        ApiConfig.diseaseReports,
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
            .map((item) => DiseaseReportModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Lists active or historical outbreak clusters.
  Future<List<OutbreakModel>> listOutbreaks({String? status}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null && status.isNotEmpty && status != 'All Statuses') {
        queryParams['status'] = status.toUpperCase();
      }
      final response = await _dio.get(
        ApiConfig.outbreaks,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        return data.map((item) => OutbreakModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves high-risk outbreak clusters.
  Future<List<OutbreakModel>> getHighRiskOutbreaks() async {
    try {
      final response = await _dio.get('${ApiConfig.outbreaks}/high-risk');
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        return data.map((item) => OutbreakModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves epidemiological summary statistics.
  Future<OutbreakStatisticsModel> getOutbreakStatistics() async {
    try {
      final response = await _dio.get('${ApiConfig.outbreaks}/statistics');
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      return OutbreakStatisticsModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves details for a specific outbreak cluster.
  Future<OutbreakModel> getOutbreakById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.outbreaks}/$id');
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      return OutbreakModel.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Retrieves reports contributing to an outbreak cluster.
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.outbreaks}/$id/reports');
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        return data.map((item) => DiseaseReportModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  /// Searches nearby disease reports within geographic radius in kilometers.
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) async {
    try {
      final response = await _dio.get(
        '${ApiConfig.diseaseReports}/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radiusKm': radiusKm,
        },
      );
      final responseData = response.data;
      final dynamic data = (responseData is Map<String, dynamic> && responseData.containsKey('data'))
          ? responseData['data']
          : responseData;

      if (data is List) {
        return data.map((item) => NearbyReportModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
