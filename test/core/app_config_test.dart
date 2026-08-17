import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/config/app_config.dart';
import 'package:vetra/core/config/api_config.dart';

void main() {
  group('AppConfig Environment Tests', () {
    tearDown(() {
      // Restore default staging environment
      AppConfig.useStaging();
    });

    test('Default environment is Staging', () {
      AppConfig.useStaging();
      expect(AppConfig.environment, Environment.staging);
      expect(AppConfig.baseUrl, 'https://api.vetra.dpdns.org');
      expect(AppConfig.apiBaseUrl, 'https://api.vetra.dpdns.org/api/v1');
      expect(ApiConfig.baseUrl, 'https://api.vetra.dpdns.org');
    });

    test('Switching to Development environment changes base URL', () {
      AppConfig.useDevelopment();
      expect(AppConfig.environment, Environment.development);
      expect(AppConfig.baseUrl, contains(':8080'));
    });

    test('Switching to Production environment changes base URL', () {
      AppConfig.useProduction();
      expect(AppConfig.environment, Environment.production);
      expect(AppConfig.baseUrl, 'https://api.vetra.app');
    });

    test('Timeouts and retry parameters are properly configured', () {
      expect(AppConfig.connectTimeout.inSeconds, 15);
      expect(AppConfig.receiveTimeout.inSeconds, 15);
      expect(AppConfig.sendTimeout.inSeconds, 15);
      expect(AppConfig.maxRetries, 3);
      expect(AppConfig.retryBaseDelay.inMilliseconds, 500);
      expect(AppConfig.retryMaxDelay.inSeconds, 3);
    });

    test('ApiConfig paths are correctly formatted with /api/v1', () {
      expect(ApiConfig.farmerRegister, '/api/v1/auth/farmer/register');
      expect(ApiConfig.farmerLogin, '/api/v1/auth/farmer/login');
      expect(ApiConfig.vetRegister, '/api/v1/auth/vet/register');
      expect(ApiConfig.vetLogin, '/api/v1/auth/vet/login');
      expect(ApiConfig.refresh, '/api/v1/auth/refresh');
      expect(ApiConfig.animals, '/api/v1/animals');
      expect(ApiConfig.appointments, '/api/v1/appointments');
      expect(ApiConfig.medicalRecords, '/api/v1/medical-records');
      expect(ApiConfig.dashboard, '/api/v1/dashboard');
    });
  });
}
