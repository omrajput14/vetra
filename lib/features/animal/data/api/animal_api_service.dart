import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';

class AnimalApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> createAnimal(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConfig.animals, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> listAnimals() async {
    try {
      final response = await _dio.get(ApiConfig.animals);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAnimalById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.animals}/$id');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateAnimal(String id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.put('${ApiConfig.animals}/$id', data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<void> deleteAnimal(String id) async {
    try {
      await _dio.delete('${ApiConfig.animals}/$id');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> searchAnimals({
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (tagNumber != null && tagNumber.isNotEmpty) queryParams['tagNumber'] = tagNumber;
      if (qrCodeId != null && qrCodeId.isNotEmpty) queryParams['qrCodeId'] = qrCodeId;
      if (species != null && species.isNotEmpty) queryParams['species'] = species;
      if (breed != null && breed.isNotEmpty) queryParams['breed'] = breed;
      if (gender != null && gender.isNotEmpty) queryParams['gender'] = gender;

      final response = await _dio.get(ApiConfig.animalSearch, queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
