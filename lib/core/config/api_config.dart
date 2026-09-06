import 'app_config.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl => AppConfig.baseUrl;

  static Duration get connectTimeout => AppConfig.connectTimeout;
  static Duration get receiveTimeout => AppConfig.receiveTimeout;
  static Duration get sendTimeout => AppConfig.sendTimeout;

  // Auth Endpoints
  static const String farmerRegister = '/api/v1/auth/farmer/register';
  static const String farmerLogin = '/api/v1/auth/farmer/login';
  static const String vetRegister = '/api/v1/auth/vet/register';
  static const String vetLogin = '/api/v1/auth/vet/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String logout = '/api/v1/auth/logout';
  static const String changePassword = '/api/v1/auth/change-password';
  static const String profileUpdate = '/api/v1/auth/profile';
  static const String me = '/api/v1/auth/me';
  static const String vets = '/api/v1/auth/vets';

  // Animal Endpoints
  static const String animals = '/api/v1/animals';
  static const String animalSearch = '/api/v1/animals/search';

  // Dashboard Endpoint (Single unified call)
  static const String dashboard = '/api/v1/dashboard';

  // Appointment Endpoints
  static const String appointments = '/api/v1/appointments';

  // Medical Record Endpoints
  static const String medicalRecords = '/api/v1/medical-records';
  static const String animalMedicalHistory = '/api/v1/animals';

  // Disease Surveillance Endpoints
  static const String diseaseReports = '/api/v1/disease/reports';
  static const String outbreaks = '/api/v1/disease/outbreaks';
  static const String diseaseRegistry = '/api/v1/disease/registry';

  // Mortality Endpoints
  static const String mortalities = '/api/v1/mortalities';

}
