import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080'
        : 'http://localhost:8080';
  }

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

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

  // Animal Endpoints
  static const String animals = '/api/v1/animals';
  static const String animalSearch = '/api/v1/animals/search';

  // Dashboard Endpoint (Single unified call)
  static const String dashboard = '/api/v1/dashboard';

  // Appointment Endpoints
  static const String appointments = '/api/v1/appointments';
}
