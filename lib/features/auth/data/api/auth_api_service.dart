import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';

class AuthApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> registerFarmer(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConfig.farmerRegister, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> registerVet(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConfig.vetRegister, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> loginFarmer(String identifier, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.farmerLogin,
        data: {'identifier': identifier, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> loginVet(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.vetLogin,
        data: {'identifier': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _dio.get(ApiConfig.me);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> body) async {
    try {
      final response = await _dio.put(ApiConfig.profileUpdate, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(ApiConfig.logout, data: {'refreshToken': refreshToken});
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      await _dio.post(
        ApiConfig.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (latitude != null) queryParams['latitude'] = latitude;
      if (longitude != null) queryParams['longitude'] = longitude;
      if (radiusKm != null) queryParams['radiusKm'] = radiusKm;
      if (village != null && village.trim().isNotEmpty) queryParams['village'] = village.trim();
      if (taluka != null && taluka.trim().isNotEmpty) queryParams['taluka'] = taluka.trim();
      if (district != null && district.trim().isNotEmpty) queryParams['district'] = district.trim();

      final response = await _dio.get(
        ApiConfig.vets,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      final data = response.data['data'] as List;
      return data.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> uploadProfilePhoto(String filePath) async {
    try {
      final fileName = filePath.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });
      final response = await _dio.post(
        '/api/v1/users/profile/photo',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<void> deleteProfilePhoto() async {
    try {
      await _dio.delete('/api/v1/users/profile/photo');
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}