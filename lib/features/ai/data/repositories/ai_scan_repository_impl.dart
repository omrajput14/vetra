import '../../data/api/ai_scan_api_service.dart';
import '../../data/models/ai_scan_model.dart';
import '../../domain/repositories/ai_scan_repository.dart';

class AIScanRepositoryImpl implements AIScanRepository {
  final AIScanApiService _apiService;

  AIScanRepositoryImpl({AIScanApiService? apiService})
      : _apiService = apiService ?? AIScanApiService();

  @override
  Future<AIScanModel> createScan({
    required String animalId,
    required String imagePath,
  }) {
    return _apiService.createScan(animalId: animalId, imagePath: imagePath);
  }

  @override
  Future<AIScanModel> getScanById(String scanId) {
    return _apiService.getScanById(scanId);
  }
}
