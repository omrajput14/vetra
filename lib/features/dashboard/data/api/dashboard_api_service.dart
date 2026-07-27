import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/network_exceptions.dart';

class DashboardApiService {
  final Dio _dio = ApiClient.instance.dio;

  Future<Map<String, dynamic>> getDashboardMetrics() async {
    try {
      final response = await _dio.get(ApiConfig.dashboard);
      return response.data;
    } on DioException catch (e) {
      throw NetworkException.fromDioError(e);
    }
  }
}
