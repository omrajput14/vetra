import '../../domain/repositories/disease_repository.dart';
import '../api/disease_api_service.dart';
import '../models/disease_report_dto.dart';
import '../models/outbreak_dto.dart';

class DiseaseRepositoryImpl implements DiseaseRepository {
  final DiseaseApiService _apiService;

  DiseaseRepositoryImpl({DiseaseApiService? apiService})
      : _apiService = apiService ?? DiseaseApiService();

  @override
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto, {String? idempotencyKey}) {
    return _apiService.createDiseaseReport(dto, idempotencyKey: idempotencyKey);
  }

  @override
  Future<DiseaseReportModel> getDiseaseReport(String id) {
    return _apiService.getDiseaseReport(id);
  }

  @override
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20}) {
    return _apiService.listMyDiseaseReports(page: page, size: size);
  }

  @override
  Future<List<OutbreakModel>> listOutbreaks({String? status}) {
    return _apiService.listOutbreaks(status: status);
  }

  @override
  Future<List<OutbreakModel>> getHighRiskOutbreaks() {
    return _apiService.getHighRiskOutbreaks();
  }

  @override
  Future<OutbreakStatisticsModel> getOutbreakStatistics() {
    return _apiService.getOutbreakStatistics();
  }

  @override
  Future<OutbreakModel> getOutbreakById(String id) {
    return _apiService.getOutbreakById(id);
  }

  @override
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id) {
    return _apiService.getReportsForOutbreak(id);
  }

  @override
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  }) {
    return _apiService.searchNearbyReports(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    );
  }
}

