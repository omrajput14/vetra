import '../../data/models/mortality_dto.dart';

abstract class MortalityRepository {
  Future<MortalityReportModel> reportMortality(CreateMortalityReportDto dto);
  Future<MortalityReportModel> getMortalityById(String id);
  Future<MortalityReportModel> getMortalityByAnimalId(String animalId);
  Future<List<MortalityReportModel>> listFarmerMortalities({int page = 0, int size = 20});
  Future<List<String>> getDiseaseCatalog();

  Future<List<MortalityReportModel>> getPendingMortalityCases({int page = 0, int size = 20});
  Future<MortalityReportModel> confirmMortality(String id, ConfirmMortalityDto dto);
  Future<MortalityReportModel> rejectMortality(String id, RejectMortalityDto dto);
  Future<List<MortalityAuditDto>> getMortalityAudits(String id);
}
