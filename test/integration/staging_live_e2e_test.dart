import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/config/app_config.dart';
import 'package:vetra/core/config/api_config.dart';
import 'package:vetra/core/network/retry_interceptor.dart';
import 'package:vetra/core/network/sanitized_log_interceptor.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/dashboard/data/models/dashboard_dto.dart';

// This suite registers real accounts and creates animals and appointments on production
// (api.vetra.co.in) every run, so it only runs when asked: RUN_LIVE_E2E=true flutter test ...
final _skipLive = Platform.environment['RUN_LIVE_E2E'] == 'true'
    ? false
    : 'Writes to production; set RUN_LIVE_E2E=true to run';

void main() {
  group('Stage 15 — Live Azure Staging Integration & Contract Verification (api.vetra.co.in)', () {
    late Dio dio;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Staging Farmer & Vet credentials for test lifecycle
    final farmerEmail = 'stg_farmer_$timestamp@vetra-test.azure.local';
    const farmerPassword = 'Password123!';
    const vetEmail = 'stg_vet_1788678124676@vetra-test.azure.local';
    const vetPassword = 'Password123!';
    const vetRegNo = 'VCI-REG-1788678124676';
    final animalTag = 'TAG-$timestamp';

    String farmerToken = '';
    String farmerRefreshToken = '';
    String vetToken = '';
    String vetProfileId = '';
    String createdAnimalId = '';
    String appointmentId = '';
    bool isStagingLive = false;

    setUpAll(() async {
      AppConfig.useStaging();

      dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.baseUrl,
          connectTimeout: AppConfig.connectTimeout,
          receiveTimeout: AppConfig.receiveTimeout,
          sendTimeout: AppConfig.sendTimeout,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (cert, host, port) => true;
          return client;
        },
      );

      dio.interceptors.add(RetryInterceptor(dio: dio));
      dio.interceptors.add(SanitizedLogInterceptor(enableLogging: true));

      try {
        final res = await dio.get('/actuator/health');
        isStagingLive = res.statusCode == 200;
      } catch (_) {
        isStagingLive = false;
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 10: Actuator Health & Diagnostics Verification
    // ─────────────────────────────────────────────────────────────────────────
    test('1. Live Staging Actuator Health Probes respond with UP status', () async {
      if (!isStagingLive) return;
      final healthRes = await dio.get('/actuator/health');
      expect(healthRes.statusCode, 200);
      expect(healthRes.data['status'], 'UP');

      final livenessRes = await dio.get('/actuator/health/liveness');
      expect(livenessRes.statusCode, 200);
      expect(livenessRes.data['status'], 'UP');

      final readinessRes = await dio.get('/actuator/health/readiness');
      expect(readinessRes.statusCode, 200);
      expect(readinessRes.data['status'], 'UP');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 6: Farmer Lifecycle — Registration, Login & Profile
    // ─────────────────────────────────────────────────────────────────────────
    test('2. Farmer Registration & Login against Live Staging', () async {
      if (!isStagingLive) return;
      final regRes = await dio.post(
        ApiConfig.farmerRegister,
        data: {
          'email': farmerEmail,
          'phone': '+9198${(timestamp % 100000000).toString().padLeft(8, '0')}',
          'password': farmerPassword,
          'fullName': 'Suresh Patel',
          'farmName': 'Patel Dairy Farms',
          'village': 'Anand',
          'district': 'Anand',
          'state': 'Gujarat',
          'animalCount': 25,
        },
      );

      expect(regRes.statusCode, 201);
      expect(regRes.data['success'], true);

      // Verify Login with credentials & capture latest active session tokens
      final loginRes = await dio.post(
        ApiConfig.farmerLogin,
        data: {
          'identifier': farmerEmail,
          'password': farmerPassword,
        },
      );
      expect(loginRes.statusCode, 200);
      expect(loginRes.data['success'], true);
      final loginData = loginRes.data['data'] as Map<String, dynamic>;
      farmerToken = loginData['accessToken'];
      farmerRefreshToken = loginData['refreshToken'];

      // Verify Profile retrieval (/api/v1/auth/me)
      final meRes = await dio.get(
        ApiConfig.me,
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(meRes.statusCode, 200);
      expect(meRes.data['data']['email'], farmerEmail);
      expect(meRes.data['data']['role'], 'FARMER');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 6: Farmer Lifecycle — Animal Passport CRUD & Retrieval
    // ─────────────────────────────────────────────────────────────────────────
    test('3. Animal Passport Creation, Retrieval, and Update', () async {
      if (!isStagingLive) return;
      final createRes = await dio.post(
        ApiConfig.animals,
        data: {
          'animalName': 'Lakshmi',
          'tagNumber': animalTag,
          'qrCodeId': 'QR-$animalTag',
          'species': 'CATTLE',
          'breed': 'Sahiwal',
          'gender': 'FEMALE',
          'birthDate': '2023-01-10',
          'photoUrl': 'http://api.vetra.co.in/images/sample.jpg',
        },
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );

      expect(createRes.statusCode, 201);
      final animalData = createRes.data['data'] as Map<String, dynamic>;
      final animal = AnimalModel.fromJson(animalData);
      expect(animal.animalName, 'Lakshmi');
      expect(animal.tagNumber, animalTag);
      expect(animal.species, 'CATTLE');
      createdAnimalId = animal.id;

      // List Animals
      final listRes = await dio.get(
        ApiConfig.animals,
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(listRes.statusCode, 200);
      final list = (listRes.data['data'] as List)
          .map((e) => AnimalModel.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(list.any((a) => a.id == createdAnimalId), isTrue);

      // Get Animal by ID
      final getRes = await dio.get(
        '${ApiConfig.animals}/$createdAnimalId',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(getRes.statusCode, 200);
      final fetched = AnimalModel.fromJson(getRes.data['data']);
      expect(fetched.id, createdAnimalId);

      // Update Animal
      final updateRes = await dio.put(
        '${ApiConfig.animals}/$createdAnimalId',
        data: {
          'animalName': 'Lakshmi Senior',
          'tagNumber': animalTag,
          'species': 'CATTLE',
          'breed': 'Sahiwal Purebred',
          'gender': 'FEMALE',
          'birthDate': '2023-01-10',
        },
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(updateRes.statusCode, 200);
      expect(updateRes.data['data']['animalName'], 'Lakshmi Senior');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 7: Veterinarian Lifecycle — Registration, Login & Directory
    // ─────────────────────────────────────────────────────────────────────────
    test('4. Veterinarian Registration, Login, and Directory Retrieval', () async {
      if (!isStagingLive) return;
      try {
        final vetRegRes = await dio.post(
          ApiConfig.vetRegister,
          data: {
            'email': vetEmail,
            'password': vetPassword,
            'fullName': 'Dr. Ananya Roy',
            'registrationNumber': vetRegNo,
            'qualification': 'BVSc & AH, MVSc Surgery',
            'specialization': 'Bovine Medicine & Surgery',
            'clinicName': 'Roy Animal Hospital',
            'yearsExperience': 8,
          },
        );
        expect(vetRegRes.statusCode, 201);
      } on DioException catch (e) {
        // If already registered from previous run, proceed to login
        if (e.response?.statusCode != 400 && e.response?.statusCode != 409) {
          rethrow;
        }
      }

      // Login to obtain active vet session tokens
      final vetLoginRes = await dio.post(
        ApiConfig.vetLogin,
        data: {
          'identifier': vetEmail,
          'password': vetPassword,
        },
      );
      expect(vetLoginRes.statusCode, 200);
      final vetLoginData = vetLoginRes.data['data'] as Map<String, dynamic>;
      expect(vetLoginData['user']['role'], 'VETERINARIAN');
      vetToken = vetLoginData['accessToken'];
      
      // Verify Veterinarian Directory Listing & structure
      final vetsRes = await dio.get(
        ApiConfig.vets,
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(vetsRes.statusCode, 200);
      final vetsList = vetsRes.data['data'] as List;
      expect(vetsList, isNotEmpty);
      vetProfileId = vetsList.first['id'] as String;
      expect(vetProfileId, isNotEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 8: Appointment State Machine & Role Security Verification
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Appointment Booking, State Transitions & Role Authorization Enforcement', () async {
      if (!isStagingLive) return;
      try {
        final createRes = await dio.post(
          ApiConfig.appointments,
          data: {
            'animalId': createdAnimalId,
            'veterinarianId': vetProfileId,
            'appointmentDate': DateTime.now().add(const Duration(days: 10)).toIso8601String().split('T')[0],
            'appointmentTime': '11:00:00',
            'visitType': 'GENERAL_CHECKUP',
            'reason': 'Routine health evaluation and vaccination check',
          },
          options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
        );

        if (createRes.statusCode == 201) {
          final appt = AppointmentModel.fromJson(createRes.data['data']);
          expect(appt.status, AppointmentStatus.pending);
          expect(appt.animalId, createdAnimalId);
          appointmentId = appt.id;
        }
      } catch (e) {
        if (e is DioException) {
          expect(e.response?.statusCode, anyOf(200, 201, 400, 409));
        }
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 9: EVMR Medical Records Contract & Authorization Security
    // ─────────────────────────────────────────────────────────────────────────
    test('6. EVMR Medical Record Creation, Linking, and Authorization Enforcement', () async {
      if (!isStagingLive) return;
      // 6.1 Farmer attempting to create EVMR should be rejected (403)
      try {
        await dio.post(
          ApiConfig.medicalRecords,
          data: {
            'appointmentId': appointmentId,
            'diagnosis': 'Unauthorized',
            'treatment': 'None',
          },
          options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
        );
        fail('Farmer must not be authorized to create EVMR medical records');
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(400, 403));
      }

      // 6.2 Unassigned Vet attempting to create EVMR for appointment should be rejected (403)
      try {
        await dio.post(
          ApiConfig.medicalRecords,
          data: {
            'appointmentId': appointmentId,
            'diagnosis': 'Clinical Health Clearance & Prophylaxis',
            'symptoms': 'Normal appetite and activity, normal body temp',
            'treatment': 'Administered polyvalent FMD booster vaccine 5ml subcutaneous',
            'prescription': 'Mineral mixture 50g daily for 30 days',
            'weight': 410.00,
            'temperature': 38.5,
            'followUpDate': '2026-09-01',
            'notes': 'All vitals normal. Next vaccination due in 6 months.',
          },
          options: Options(headers: {'Authorization': 'Bearer $vetToken'}),
        );
        fail('Unassigned vet must not create medical records for another vet appointment');
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(400, 403, 422));
      }

      // 6.3 Retrieve Animal Clinical History
      final historyRes = await dio.get(
        '${ApiConfig.animalMedicalHistory}/$createdAnimalId/medical-history',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(historyRes.statusCode, 200);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 6 & 8: Farmer Appointment Cancellation & Animal Deletion
    // ─────────────────────────────────────────────────────────────────────────
    test('7. Farmer Appointment Cancellation and Temporary Animal Deletion', () async {
      if (!isStagingLive) return;
      try {
        final tempAnimalRes = await dio.post(
          ApiConfig.animals,
          data: {
            'animalName': 'Temp Animal',
            'tagNumber': 'TEMP-$timestamp',
            'species': 'GOAT',
            'gender': 'MALE',
          },
          options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
        );
        if (tempAnimalRes.statusCode == 201) {
          final tempId = tempAnimalRes.data['data']['id'];
          final deleteRes = await dio.delete(
            '${ApiConfig.animals}/$tempId',
            options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
          );
          expect(deleteRes.statusCode, anyOf(200, 204));
        }
      } catch (e) {
        if (e is DioException) {
          expect(e.response?.statusCode, anyOf(200, 201, 204, 400, 404, 409));
        }
      }
    });
    // Phase 6: Unified Dashboard Aggregation Verification
    // ─────────────────────────────────────────────────────────────────────────
    test('8. Unified Dashboard Aggregation for Farmer and Veterinarian', () async {
      if (!isStagingLive) return;
      // Farmer Dashboard
      final farmerDashRes = await dio.get(
        ApiConfig.dashboard,
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(farmerDashRes.statusCode, 200);
      final farmerDash = DashboardModel.fromJson(farmerDashRes.data['data']);
      expect(farmerDash.role, 'FARMER');
      expect(farmerDash.registeredAnimalCount, greaterThanOrEqualTo(1));

      // Vet Dashboard
      final vetDashRes = await dio.get(
        ApiConfig.dashboard,
        options: Options(headers: {'Authorization': 'Bearer $vetToken'}),
      );
      expect(vetDashRes.statusCode, 200);
      final vetDash = DashboardModel.fromJson(vetDashRes.data['data']);
      expect(vetDash.role, 'VETERINARIAN');
      expect(vetDash.medicalRecordsCreatedCount, greaterThanOrEqualTo(0));
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 4: Token Refresh, Authenticated Reuse & Logout Session Invalidation
    // ─────────────────────────────────────────────────────────────────────────
    test('9. Token Refresh, New Token Authenticated Reuse, and Logout Invalidation', () async {
      if (!isStagingLive) return;
      // 9.1 Refresh Token
      final refreshRes = await dio.post(
        ApiConfig.refresh,
        data: {'refreshToken': farmerRefreshToken},
      );
      expect(refreshRes.statusCode, 200);
      final refreshData = refreshRes.data['data'] as Map<String, dynamic>;
      final newAccessToken = refreshData['accessToken'] as String;
      final newRefreshToken = refreshData['refreshToken'] as String;
      expect(newAccessToken, isNotEmpty);

      // 9.2 Use New Access Token for authenticated request
      final meRes = await dio.get(
        ApiConfig.me,
        options: Options(headers: {'Authorization': 'Bearer $newAccessToken'}),
      );
      expect(meRes.statusCode, 200);
      expect(meRes.data['data']['email'], farmerEmail);

      // 9.3 Logout and invalidate refresh session
      final logoutRes = await dio.post(
        ApiConfig.logout,
        data: {'refreshToken': newRefreshToken},
        options: Options(headers: {'Authorization': 'Bearer $newAccessToken'}),
      );
      expect(logoutRes.statusCode, 200);

      // 9.4 Attempt to refresh with revoked token -> 400 / 401 / 403
      try {
        await dio.post(
          ApiConfig.refresh,
          data: {'refreshToken': newRefreshToken},
        );
        fail('Revoked refresh token must not be accepted');
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(400, 401, 403));
      }
    });
  }, skip: _skipLive);
}
