import '../../data/models/ai_scan_model.dart';

abstract class AIScanRepository {
  Future<AIScanModel> createScan({
    required String animalId,
    required String imagePath,
  });

  Future<AIScanModel> getScanById(String scanId);
}
