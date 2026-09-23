import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:vetra/core/models/user_model.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/domain/repositories/auth_repository.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/features/profile/presentation/pages/shift_settings_page.dart';
import 'package:vetra/features/profile/presentation/pages/vet_profile_page.dart';
import 'package:vetra/features/veterinarian/presentation/pages/clinical_schedule_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockAuthRepository implements AuthRepository {
  @override
  Future<String> uploadProfilePhoto(String filePath) async => '';
  @override
  Future<void> deleteProfilePhoto() async {}
  UserModel? mockUser;
  Map<String, dynamic> lastUpdatedPayload = {};

  @override
  Future<UserModel?> restoreSession() async => mockUser;

  @override
  Future<UserModel?> getCachedUser() async => mockUser;

  @override
  Future<UserModel> updateProfile({
    String? fullName,
    String? phone,
    String? farmName,
    String? village,
    String? taluka,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    String? clinicName,
    String? clinicAddress,
    String? specialization,
    String? qualification,
    int? yearsExperience,
    bool? isAvailable,
    bool? emergencyAvailable,
    String? shiftSchedule,
    String? profilePhotoUrl,
    String? certificateUrl,
  }) async {
    lastUpdatedPayload = {
      'fullName': fullName,
      'isAvailable': isAvailable,
      'emergencyAvailable': emergencyAvailable,
      'shiftSchedule': shiftSchedule,
    };
    final updatedMetadata = Map<String, dynamic>.from(mockUser?.metadata ?? {});
    if (isAvailable != null) updatedMetadata['isAvailable'] = isAvailable;
    if (emergencyAvailable != null) updatedMetadata['emergencyAvailable'] = emergencyAvailable;
    if (shiftSchedule != null) updatedMetadata['shiftSchedule'] = shiftSchedule;

    mockUser = UserModel(
      id: mockUser?.id ?? 'vet-123',
      name: fullName ?? mockUser?.name ?? 'Dr. Sharma',
      emailOrPhone: phone ?? mockUser?.emailOrPhone ?? 'sharma@vetra.org',
      role: UserRole.veterinarian,
      metadata: updatedMetadata,
    );
    return mockUser!;
  }

  @override
  Future<UserModel> loginFarmer({required String identifier, required String password}) async => throw UnimplementedError();

  @override
  Future<UserModel> loginVet({required String email, required String password}) async => mockUser!;

  @override
  Future<void> logout() async {
    mockUser = null;
  }

  @override
  Future<UserModel> registerFarmer({required String email, required String fullName, String? phone, required String password, String? farmName, String? village, String? taluka, String? district, String? state, double? latitude, double? longitude, int? animalCount, String? preferredLanguage}) async => throw UnimplementedError();

  @override
  Future<UserModel> registerVet({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String regNo,
    required String qualification,
    required String specialization,
    String? clinicName,
    String? clinicAddress,
    String? village,
    String? taluka,
    String? district,
    String? state,
    double? latitude,
    double? longitude,
    required String experience,
    String? preferredLanguage,
  }) async => throw UnimplementedError();

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}

  @override
  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async => [];
}

class MockAppointmentRepository implements AppointmentRepository {
  List<AppointmentModel> appointments = [];
  bool shouldThrow = false;

  @override
  Future<List<AppointmentModel>> listAppointments() async {
    if (shouldThrow) throw Exception('Network timeout connecting to server');
    return appointments;
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    return appointments.firstWhere((a) => a.id == id);
  }

  @override
  Future<AppointmentModel> createAppointment({required String animalId, required String veterinarianId, required String appointmentDate, required String appointmentTime, required VisitType visitType, required String reason}) async => throw UnimplementedError();

  @override
  Future<AppointmentModel> confirmAppointment(String id) async {
    final idx = appointments.indexWhere((a) => a.id == id);
    final current = appointments[idx];
    final updated = AppointmentModel(
      id: current.id,
      farmerId: current.farmerId,
      farmerName: current.farmerName,
      farmerPhone: current.farmerPhone,
      veterinarianId: current.veterinarianId,
      veterinarianName: current.veterinarianName,
      clinicName: current.clinicName,
      animalId: current.animalId,
      animalName: current.animalName,
      tagNumber: current.tagNumber,
      species: current.species,
      appointmentDate: current.appointmentDate,
      appointmentTime: current.appointmentTime,
      visitType: current.visitType,
      reason: current.reason,
      status: AppointmentStatus.confirmed,
    );
    appointments[idx] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> rejectAppointment(String id, {String? reason}) async {
    final idx = appointments.indexWhere((a) => a.id == id);
    final current = appointments[idx];
    final updated = AppointmentModel(
      id: current.id,
      farmerId: current.farmerId,
      veterinarianId: current.veterinarianId,
      animalId: current.animalId,
      appointmentDate: current.appointmentDate,
      appointmentTime: current.appointmentTime,
      visitType: current.visitType,
      reason: current.reason,
      status: AppointmentStatus.rejected,
    );
    appointments[idx] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> completeAppointment(String id, {String? notes}) async {
    final idx = appointments.indexWhere((a) => a.id == id);
    final current = appointments[idx];
    final updated = AppointmentModel(
      id: current.id,
      farmerId: current.farmerId,
      veterinarianId: current.veterinarianId,
      animalId: current.animalId,
      appointmentDate: current.appointmentDate,
      appointmentTime: current.appointmentTime,
      visitType: current.visitType,
      reason: current.reason,
      status: AppointmentStatus.completed,
      veterinarianNotes: notes,
    );
    appointments[idx] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async => throw UnimplementedError();

  @override
  Future<AppointmentModel> startEnRoute(String id) async => throw UnimplementedError();

  @override
  Future<AppointmentModel> markArrived(String id) async => throw UnimplementedError();

  @override
  Future<AppointmentLiveLocationDto> updateLocation(String id, double latitude, double longitude, {double? accuracy}) async =>
      AppointmentLiveLocationDto(isLive: true);

  @override
  Future<AppointmentLiveLocationDto> getLiveLocation(String id) async =>
      AppointmentLiveLocationDto(isLive: false);

  @override
  Future<List<dynamic>> getMessages(String appointmentId) async => [];

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String appointmentId,
    required String content,
    String? messageType,
    String? treatmentPayloadJson,
  }) async => {
    'data': {
      'id': 'msg-1',
      'appointmentId': appointmentId,
      'senderId': 'user-1',
      'senderName': 'Test User',
      'senderRole': 'VETERINARIAN',
      'recipientId': 'user-2',
      'messageType': messageType ?? 'TEXT',
      'content': content,
      'treatmentPayloadJson': treatmentPayloadJson,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    }
  };
}

Widget _createTestApp(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: child,
  );
}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockAppointmentRepository mockApptRepo;

  setUp(() {
    mockAuthRepo = MockAuthRepository();
    mockApptRepo = MockAppointmentRepository();

    final customSchedule = {
      'monday': {'isWorking': true, 'start': '09:00', 'end': '17:00'},
      'tuesday': {'isWorking': true, 'start': '09:00', 'end': '17:00'},
      'wednesday': {'isWorking': false, 'start': '09:00', 'end': '17:00'},
      'thursday': {'isWorking': true, 'start': '09:00', 'end': '17:00'},
      'friday': {'isWorking': true, 'start': '09:00', 'end': '17:00'},
      'saturday': {'isWorking': true, 'start': '09:00', 'end': '14:00'},
      'sunday': {'isWorking': false, 'start': '09:00', 'end': '13:00'},
    };

    mockAuthRepo.mockUser = UserModel(
      id: 'vet-uuid-99',
      name: 'Dr. Anand Deshmukh',
      emailOrPhone: 'anand@vetra.mahagov.in',
      role: UserRole.veterinarian,
      metadata: {
        'clinicName': 'Pune Central Veterinary Hospital',
        'qualification': 'BVSc & AH, MVSc Surgery',
        'specialization': 'Large Animal Surgery',
        'yearsExperience': 8,
        'registrationNumber': 'MH-VET-9821',
        'isAvailable': true,
        'emergencyAvailable': true,
        'shiftSchedule': jsonEncode(customSchedule),
      },
    );

    mockApptRepo.appointments = [
      AppointmentModel(
        id: 'appt-1',
        farmerId: 'farmer-1',
        farmerName: 'Demo Farmer',
        farmerPhone: '+91 98230 11223',
        veterinarianId: 'vet-uuid-99',
        veterinarianName: 'Dr. Anand Deshmukh',
        clinicName: 'Pune Central Veterinary Hospital',
        animalId: 'animal-1',
        animalName: 'hi',
        tagNumber: 'hi',
        species: 'BUFFALO',
        appointmentDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        appointmentTime: '10:00:00',
        visitType: VisitType.generalCheckup,
        reason: 'Lethargy and mild fever',
        status: AppointmentStatus.confirmed,
      ),
      AppointmentModel(
        id: 'appt-2',
        farmerId: 'farmer-2',
        farmerName: 'Ramesh Patil',
        farmerPhone: '+91 98230 44556',
        veterinarianId: 'vet-uuid-99',
        animalId: 'animal-2',
        animalName: 'Gauri',
        tagNumber: 'TAG-CATTLE-99',
        species: 'CATTLE',
        appointmentDate: DateFormat('yyyy-MM-dd').format(DateTime.now().add(const Duration(days: 1))),
        appointmentTime: '11:30:00',
        visitType: VisitType.vaccination,
        reason: 'FMD vaccination booster dose',
        status: AppointmentStatus.pending,
      ),
    ];
    authNotifier.setRepository(mockAuthRepo);
    authNotifier.setCurrentUser(mockAuthRepo.mockUser);
    appointmentNotifier.setRepository(mockApptRepo);
  });

  group('Vet Profile & Shift Settings Tests', () {
    testWidgets('ShiftSettingsPage loads saved working days and ON/OFF states', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ShiftSettingsPage()));
      await tester.pumpAndSettle();

      expect(find.text('Availability & Shift Settings'), findsOneWidget);
      expect(find.text('General Consultation Duty'), findsOneWidget);
      expect(find.text('24/7 Emergency Response'), findsOneWidget);
      expect(find.text('Weekly Working Hours'), findsOneWidget);
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('Save Shift Settings'), findsOneWidget);
    });

    testWidgets('ShiftSettingsPage saves updated shift schedule to backend', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ShiftSettingsPage()));
      await tester.pumpAndSettle();

      // Tap Mon-Fri Standard shortcut button
      await tester.tap(find.text('Mon–Fri Standard'));
      await tester.pumpAndSettle();

      // Tap Save Shift Settings
      await tester.tap(find.text('Save Shift Settings'));
      await tester.pumpAndSettle();

      expect(mockAuthRepo.lastUpdatedPayload['shiftSchedule'], isNotNull);
      final Map<String, dynamic> savedSchedule = jsonDecode(mockAuthRepo.lastUpdatedPayload['shiftSchedule']);
      expect(savedSchedule['monday']['isWorking'], isTrue);
      expect(savedSchedule['monday']['start'], equals('09:00'));
      expect(savedSchedule['monday']['end'], equals('17:00'));
    });

    testWidgets('ShiftSettingsPage turns OFF General Consultation and 24/7 Emergency and saves false to backend', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const ShiftSettingsPage()));
      await tester.pumpAndSettle();

      // Find switch widgets (2 status switches + 7 weekday switches)
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(9));

      // Tap the top two switches to turn them OFF
      await tester.tap(switches.at(0));
      await tester.pumpAndSettle();
      await tester.tap(switches.at(1));
      await tester.pumpAndSettle();

      // Verify UI displays paused status text
      expect(find.text('Currently paused / On leave'), findsOneWidget);

      // Tap Save Shift Settings
      await tester.tap(find.text('Save Shift Settings'));
      await tester.pumpAndSettle();

      // Verify mock repository received false for both flags
      expect(mockAuthRepo.lastUpdatedPayload['isAvailable'], isFalse);
      expect(mockAuthRepo.lastUpdatedPayload['emergencyAvailable'], isFalse);
    });

    testWidgets('VetProfilePage renders live Duty status and links to Shift Settings and Clinical Schedule',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(_createTestApp(const VetProfilePage()));
      await tester.pumpAndSettle();

      expect(find.text('Duty Status'), findsOneWidget);
      expect(find.text('Available for On-Call & Triage'), findsOneWidget);
      expect(find.text('Availability & Shift Settings'), findsOneWidget);
      expect(find.text('My Clinical Schedule'), findsOneWidget);

      // Toggle Duty Status off
      final dutySwitch = find.byType(Switch).first;
      await tester.tap(dutySwitch);
      await tester.pumpAndSettle();

      expect(mockAuthRepo.lastUpdatedPayload['isAvailable'], isFalse);
    });

    test('UserModel correctly resolves isAvailable and emergencyAvailable across diverse serialization keys', () {
      const user1 = UserModel(
        id: 'u1',
        name: 'Vet 1',
        emailOrPhone: 'v1@vet.org',
        role: UserRole.veterinarian,
        metadata: {'available': false, 'emergency_available': false},
      );
      expect(user1.isAvailable, isFalse);
      expect(user1.emergencyAvailable, isFalse);

      const user2 = UserModel(
        id: 'u2',
        name: 'Vet 2',
        emailOrPhone: 'v2@vet.org',
        role: UserRole.veterinarian,
        metadata: {'isAvailable': false, 'isEmergencyAvailable': false},
      );
      expect(user2.isAvailable, isFalse);
      expect(user2.emergencyAvailable, isFalse);

      const user3 = UserModel(
        id: 'u3',
        name: 'Vet 3',
        emailOrPhone: 'v3@vet.org',
        role: UserRole.veterinarian,
        metadata: {'is_available': false, 'emergencyAvailable': false},
      );
      expect(user3.isAvailable, isFalse);
      expect(user3.emergencyAvailable, isFalse);
    });
  });

  group('My Clinical Schedule Tests', () {
    testWidgets('ClinicalSchedulePage renders summary metrics and appointment cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Seed appointments in mock repo & notifier
      appointmentNotifier.appointments.clear();
      appointmentNotifier.appointments.addAll(mockApptRepo.appointments);

      await tester.pumpWidget(_createTestApp(const ClinicalSchedulePage(showBottomNav: false)));
      await tester.pumpAndSettle();

      expect(find.text('My Clinical Schedule'), findsOneWidget);
      expect(find.text("Today's Visits"), findsOneWidget);
      expect(find.textContaining('Upcoming'), findsWidgets);
      expect(find.textContaining('Completed'), findsWidgets);
      expect(find.text('hi (hi)'), findsOneWidget); // Animal name and tag
      expect(find.text('Species: BUFFALO • Farmer: Demo Farmer'), findsOneWidget);
      expect(find.text('General Checkup'), findsOneWidget);
      expect(find.text('Passport'), findsNWidgets(2));
    });

    testWidgets('ClinicalSchedulePage renders empty state when no appointments exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      mockApptRepo.appointments = [];
      appointmentNotifier.appointments.clear();

      await tester.pumpWidget(_createTestApp(const ClinicalSchedulePage(showBottomNav: false)));
      await tester.pumpAndSettle();

      expect(find.text('No appointments scheduled.'), findsOneWidget);
    });
  });
}
