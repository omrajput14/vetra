import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';

class MedicalRecordApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> createMedicalRecord(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(ApiConfig.medicalRecords, data: body);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> listMedicalRecords() async {
    try {
      final response = await _dio.get(ApiConfig.medicalRecords);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMedicalRecordById(String id) async {
    try {
      final response = await _dio.get('${ApiConfig.medicalRecords}/$id');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getAnimalMedicalHistory(String animalId) async {
    try {
      final response = await _dio.get('${ApiConfig.animalMedicalHistory}/$animalId/medical-history');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> getMedicalRecordByAppointmentId(String appointmentId) async {
    try {
      final response = await _dio.get('/api/v1/appointments/$appointmentId/medical-record');
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
