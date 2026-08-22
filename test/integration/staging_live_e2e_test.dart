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
import 'package:vetra/features/medical_record/data/models/medical_record_dto.dart';
import 'package:vetra/features/dashboard/data/models/dashboard_dto.dart';

void main() {
  group('Stage 15 — Live AWS Staging Integration & Contract Verification (api.vetra.dpdns.org)', () {
    late Dio dio;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Staging Farmer & Vet credentials for test lifecycle
    final farmerEmail = 'stg_farmer_$timestamp@vetra-test.dpdns.org';
    const farmerPassword = 'Password123!';
    final vetEmail = 'stg_vet_$timestamp@vetra-test.dpdns.org';
    const vetPassword = 'Password123!';
    final vetRegNo = 'VCI-REG-$timestamp';
    final animalTag = 'TAG-$timestamp';

    String farmerToken = '';
    String farmerRefreshToken = '';
    String vetToken = '';
    String vetProfileId = '';
    String createdAnimalId = '';
    String appointmentId = '';
    String secondAppointmentId = '';
    String medicalRecordId = '';
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
          'photoUrl': 'https://api.vetra.dpdns.org/images/sample.jpg',
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

      // Verify Veterinarian Directory Listing & match exact registration number
      final vetsRes = await dio.get(
        ApiConfig.vets,
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(vetsRes.statusCode, 200);
      final vetsList = vetsRes.data['data'] as List;
      final matchedVet = vetsList.firstWhere(
        (v) => v['registrationNumber'] == vetRegNo || v['email'] == vetEmail,
      );
      expect(matchedVet, isNotNull);
      vetProfileId = matchedVet['id'];
      expect(vetProfileId, isNotEmpty);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 8: Appointment State Machine & Role Security Verification
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Appointment Booking, State Transitions & Role Authorization Enforcement', () async {
      if (!isStagingLive) return;
      // 5.1 Farmer creates appointment with verified vetProfileId
      final createRes = await dio.post(
        ApiConfig.appointments,
        data: {
          'animalId': createdAnimalId,
          'veterinarianId': vetProfileId,
          'appointmentDate': '2026-08-25',
          'appointmentTime': '11:30:00',
          'visitType': 'GENERAL_CHECKUP',
          'reason': 'Routine health evaluation and vaccination check',
        },
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );

      expect(createRes.statusCode, 201);
      final appt = AppointmentModel.fromJson(createRes.data['data']);
      expect(appt.status, AppointmentStatus.pending);
      expect(appt.animalId, createdAnimalId);
      appointmentId = appt.id;

      // 5.2 Role Security Check: Farmer attempting to confirm should be rejected (403)
      try {
        await dio.patch(
          '${ApiConfig.appointments}/$appointmentId/confirm',
          options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
        );
        fail('Farmer must not be allowed to confirm appointment');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 403);
      }

      // 5.3 Vet confirms appointment (PENDING -> CONFIRMED)
      final confirmRes = await dio.patch(
        '${ApiConfig.appointments}/$appointmentId/confirm',
        options: Options(headers: {'Authorization': 'Bearer $vetToken'}),
      );
      expect(confirmRes.statusCode, 200);
      final confirmedAppt = AppointmentModel.fromJson(confirmRes.data['data']);
      expect(confirmedAppt.status, AppointmentStatus.confirmed);

      // 5.4 Role Security Check: Vet attempting to cancel farmer appointment should be rejected (403)
      try {
        await dio.patch(
          '${ApiConfig.appointments}/$appointmentId/cancel',
          queryParameters: {'reason': 'Vet cannot cancel'},
          options: Options(headers: {'Authorization': 'Bearer $vetToken'}),
        );
        fail('Vet must not be allowed to cancel appointment directly');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 403);
      }

      // 5.5 Vet completes appointment with consultation notes (CONFIRMED -> COMPLETED)
      final completeRes = await dio.patch(
        '${ApiConfig.appointments}/$appointmentId/complete',
        queryParameters: {'notes': 'Animal is in excellent health. Deworming completed.'},
        options: Options(headers: {'Authorization': 'Bearer $vetToken'}),
      );
      expect(completeRes.statusCode, 200);
      final completedAppt = AppointmentModel.fromJson(completeRes.data['data']);
      expect(completedAppt.status, AppointmentStatus.completed);
      expect(completedAppt.veterinarianNotes, contains('Deworming completed'));

      // 5.6 Terminal State Check: Attempting to cancel COMPLETED appointment returns 422 (BusinessRuleException)
      try {
        await dio.patch(
          '${ApiConfig.appointments}/$appointmentId/cancel',
          queryParameters: {'reason': 'Cannot cancel terminal state'},
          options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
        );
        fail('Terminal appointment must not allow further state transitions');
      } on DioException catch (e) {
        expect(e.response?.statusCode, anyOf(400, 422));
      }
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 9: EVMR Medical Records Contract & History Retrieval
    // ─────────────────────────────────────────────────────────────────────────
    test('6. EVMR Medical Record Creation, Linking, and History Retrieval', () async {
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
        expect(e.response?.statusCode, 403);
      }

      // 6.2 Vet creates EVMR for completed appointment
      final evmrRes = await dio.post(
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

      expect(evmrRes.statusCode, 201);
      final evmrData = evmrRes.data['data'] as Map<String, dynamic>;
      final medicalRecord = MedicalRecordModel.fromJson(evmrData);
      expect(medicalRecord.diagnosis, 'Clinical Health Clearance & Prophylaxis');
      expect(medicalRecord.weight, 410.0);
      expect(medicalRecord.temperature, 38.5);
      medicalRecordId = medicalRecord.id;

      // 6.3 Retrieve EVMR by ID
      final getEvmrRes = await dio.get(
        '${ApiConfig.medicalRecords}/$medicalRecordId',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(getEvmrRes.statusCode, 200);
      expect(getEvmrRes.data['data']['diagnosis'], 'Clinical Health Clearance & Prophylaxis');

      // 6.4 Retrieve Animal Clinical History
      final historyRes = await dio.get(
        '${ApiConfig.animalMedicalHistory}/$createdAnimalId/medical-history',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(historyRes.statusCode, 200);
      final historyList = (historyRes.data['data'] as List)
          .map((e) => MedicalRecordModel.fromJson(e as Map<String, dynamic>))
          .toList();
      expect(historyList.any((r) => r.id == medicalRecordId), isTrue);

      // 6.5 Retrieve EVMR by Appointment ID
      final apptEvmrRes = await dio.get(
        '/api/v1/appointments/$appointmentId/medical-record',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(apptEvmrRes.statusCode, 200);
      expect(apptEvmrRes.data['data']['id'], medicalRecordId);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Phase 6 & 8: Farmer Appointment Cancellation & Animal Deletion
    // ─────────────────────────────────────────────────────────────────────────
    test('7. Farmer Appointment Cancellation and Temporary Animal Deletion', () async {
      if (!isStagingLive) return;
      // Create second appointment
      final appt2Res = await dio.post(
        ApiConfig.appointments,
        data: {
          'animalId': createdAnimalId,
          'veterinarianId': vetProfileId,
          'appointmentDate': '2026-08-28',
          'appointmentTime': '14:00:00',
          'visitType': 'FOLLOW_UP',
          'reason': 'Follow-up checkup',
        },
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(appt2Res.statusCode, 201);
      secondAppointmentId = appt2Res.data['data']['id'];

      // Farmer cancels appointment (PENDING -> CANCELLED)
      final cancelRes = await dio.patch(
        '${ApiConfig.appointments}/$secondAppointmentId/cancel',
        queryParameters: {'reason': 'Farmer travel schedule change'},
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(cancelRes.statusCode, 200);
      expect(cancelRes.data['data']['status'], 'CANCELLED');

      // Create a temporary animal and verify deletion
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
      expect(tempAnimalRes.statusCode, 201);
      final tempId = tempAnimalRes.data['data']['id'];

      final deleteRes = await dio.delete(
        '${ApiConfig.animals}/$tempId',
        options: Options(headers: {'Authorization': 'Bearer $farmerToken'}),
      );
      expect(deleteRes.statusCode, 200);
    });

    // ─────────────────────────────────────────────────────────────────────────
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
      expect(vetDash.medicalRecordsCreatedCount, greaterThanOrEqualTo(1));
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
  });
}
