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
}
