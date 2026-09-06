import '../../data/models/disease_report_dto.dart';
import '../../data/models/outbreak_dto.dart';

/// Contract for Disease surveillance repository operations.
abstract class DiseaseRepository {
  Future<DiseaseReportModel> createDiseaseReport(CreateDiseaseReportDto dto);
  Future<DiseaseReportModel> getDiseaseReport(String id);
  Future<List<DiseaseReportModel>> listMyDiseaseReports({int page = 0, int size = 20});
  Future<List<OutbreakModel>> listOutbreaks({String? status});
  Future<List<OutbreakModel>> getHighRiskOutbreaks();
  Future<OutbreakStatisticsModel> getOutbreakStatistics();
  Future<OutbreakModel> getOutbreakById(String id);
  Future<List<DiseaseReportModel>> getReportsForOutbreak(String id);
  Future<List<NearbyReportModel>> searchNearbyReports({
    required double latitude,
    required double longitude,
    double radiusKm = 25.0,
  });
}

