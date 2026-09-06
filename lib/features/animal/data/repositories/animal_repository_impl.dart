import '../../data/api/animal_api_service.dart';
import '../../data/models/animal_dto.dart';
import '../../data/models/animal_health_record_dto.dart';
import '../../domain/repositories/animal_repository.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalApiService _apiService = AnimalApiService();

  @override
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
  }) async {
    final response = await _apiService.createAnimal({
      'animalName': animalName,
      'tagNumber': tagNumber,
      'qrCodeId': qrCodeId,
      'species': species.toUpperCase(),
      'breed': breed,
      'gender': gender.toUpperCase(),
      'birthDate': birthDate,
      'photoUrl': photoUrl,
    });
    return AnimalModel.fromJson(response['data']);
  }

  @override
  Future<List<AnimalModel>> listAnimals() async {
    final response = await _apiService.listAnimals();
    final list = response['data'] as List;
    return list.map((json) => AnimalModel.fromJson(json)).toList();
  }

  @override
  Future<AnimalModel> getAnimalById(String id) async {
    final response = await _apiService.getAnimalById(id);
    return AnimalModel.fromJson(response['data']);
  }

  @override
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
  }) async {
    final response = await _apiService.updateAnimal(id, {
      'animalName': animalName,
      'tagNumber': tagNumber,
      'qrCodeId': qrCodeId,
      'species': species.toUpperCase(),
      'breed': breed,
      'gender': gender.toUpperCase(),
      'birthDate': birthDate,
      'photoUrl': photoUrl,
    });
    return AnimalModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteAnimal(String id) async {
    await _apiService.deleteAnimal(id);
  }

  @override
  Future<List<AnimalModel>> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  }) async {
    final response = await _apiService.searchAnimals(
      tagNumber: tagNumber,
      qrCodeId: qrCodeId,
      species: species?.toUpperCase(),
      breed: breed,
      gender: gender?.toUpperCase(),
    );
    final list = response['data'] as List;
    return list.map((json) => AnimalModel.fromJson(json)).toList();
  }

  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) async {
    final response = await _apiService.getAnimalHealthRecords(animalId);
    final list = response['data'] as List;
    return list.map((json) => AnimalHealthRecordModel.fromJson(json)).toList();
  }

  @override
  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body) async {
    final response = await _apiService.createHealthRecord(animalId, body);
    return AnimalHealthRecordModel.fromJson(response['data']);
  }

  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) async {
    final response = await _apiService.getLatestHealthStatus(animalId);
    return AnimalHealthStatusModel.fromJson(response['data']);
  }

  @override
  Future<String> uploadAnimalPhoto(String animalId, String filePath) async {
    final response = await _apiService.uploadAnimalPhoto(animalId, filePath);
    final data = response['data'] as Map<String, dynamic>?;
    return data?['photoUrl']?.toString() ?? '';
  }

  @override
  Future<void> deleteAnimalPhoto(String animalId) async {
    await _apiService.deleteAnimalPhoto(animalId);
  }
}
