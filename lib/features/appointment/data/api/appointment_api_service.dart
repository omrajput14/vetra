import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';

class AppointmentApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> createAppointment(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConfig.appointments, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> listAppointments() async {
    try {
      final response = await _dio.get(ApiConfig.appointments);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAppointmentById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.appointments}/$id');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateStatus(String id, Map<String, dynamic> body) async {
    try {
      final response = await _dio.patch('${ApiConfig.appointments}/$id/status', data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> confirmAppointment(String id) async {
    try {
      final response = await _dio.patch('${ApiConfig.appointments}/$id/confirm');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> rejectAppointment(String id, {String? reason}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) queryParams['reason'] = reason;
      final response = await _dio.patch('${ApiConfig.appointments}/$id/reject', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> completeAppointment(String id, {String? notes}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (notes != null && notes.isNotEmpty) queryParams['notes'] = notes;
      final response = await _dio.patch('${ApiConfig.appointments}/$id/complete', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> cancelAppointment(String id, {String? reason}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) queryParams['reason'] = reason;
      final response = await _dio.patch('${ApiConfig.appointments}/$id/cancel', queryParameters: queryParams);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
