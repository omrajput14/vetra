import '../../data/models/animal_dto.dart';
import '../../data/models/animal_health_record_dto.dart';

abstract class AnimalRepository {
  Future<AnimalModel> createAnimal({
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
  });

  Future<List<AnimalModel>> listAnimals();

  Future<AnimalModel> getAnimalById(String id);

  Future<AnimalModel> updateAnimal({
    required String id,
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
    String? localPhotoPath,
  });

  Future<void> deleteAnimal(String id);

  Future<List<AnimalModel>> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  });

  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId);

  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body);

  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId);

  Future<String> uploadAnimalPhoto(String animalId, String filePath);
  Future<void> deleteAnimalPhoto(String animalId);
}
