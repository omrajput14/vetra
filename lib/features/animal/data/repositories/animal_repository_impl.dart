import '../../data/api/animal_api_service.dart';
import '../../data/models/animal_dto.dart';
import '../../domain/repositories/animal_repository.dart';

class AnimalRepositoryImpl implements AnimalRepository {
  final AnimalApiService _apiService = AnimalApiService();

  @override
  Future<AnimalModel> createAnimal({
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
  }) async {
    final response = await _apiService.createAnimal({
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
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate,
    String? photoUrl,
  }) async {
    final response = await _apiService.updateAnimal(id, {
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
}
