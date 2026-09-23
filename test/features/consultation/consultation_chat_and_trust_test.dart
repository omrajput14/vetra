import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/models/user_model.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/data/models/animal_health_record_dto.dart';
import 'package:vetra/features/animal/domain/repositories/animal_repository.dart';
import 'package:vetra/features/animal/presentation/pages/animal_timeline_page.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:vetra/features/appointment/presentation/pages/appointment_chat_page.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/domain/repositories/auth_repository.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/features/shared/presentation/pages/appointment_booking_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

class MockTestAnimalRepository implements AnimalRepository {
  @override
  Future<String> uploadAnimalPhoto(String animalId, String filePath) async => '';
  @override
  Future<void> deleteAnimalPhoto(String animalId) async {}
  List<AnimalModel> mockAnimals = [];
  Map<String, List<AnimalHealthRecordModel>> mockRecords = {};

  @override
  Future<List<AnimalModel>> listAnimals() async => mockAnimals;

  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) async =>
      mockRecords[animalId] ?? [];

  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) async =>
      AnimalHealthStatusModel(animalId: animalId, status: 'HEALTHY', statusSummary: 'Healthy');

  @override
  Future<AnimalModel> createAnimal({
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate, String? localPhotoPath,
    String? photoUrl,
  }) async => throw UnimplementedError();

  @override
  Future<AnimalModel> getAnimalById(String id) async => mockAnimals.firstWhere((a) => a.id == id);

  @override
  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body) async =>
      throw UnimplementedError();

  @override
  Future<AnimalModel> updateAnimal({
    required String id,
    String? animalName,
    required String tagNumber,
    String? qrCodeId,
    required String species,
    String? breed,
    required String gender,
    String? birthDate, String? localPhotoPath,
    String? photoUrl,
  }) async => throw UnimplementedError();

  @override
  Future<void> deleteAnimal(String id) async {}

  @override
  Future<List<AnimalModel>> searchAnimals({
    String? animalName,
    String? tagNumber,
    String? qrCodeId,
    String? species,
    String? breed,
    String? gender,
  }) async => mockAnimals;
}

class MockTestAppointmentRepository implements AppointmentRepository {
  List<AppointmentModel> mockAppointments = [];
  Map<String, List<Map<String, dynamic>>> mockMessages = {};

  @override
  Future<List<AppointmentModel>> listAppointments() async => mockAppointments;

  @override
  Future<AppointmentModel> getAppointmentById(String id) async =>
      mockAppointments.firstWhere((a) => a.id == id);

  @override
  Future<AppointmentModel> createAppointment({
    required String animalId,
    required String veterinarianId,
    required String appointmentDate,
    required String appointmentTime,
    required VisitType visitType,
    required String reason,
  }) async {
    final app = AppointmentModel(
      id: 'appt-new',
      farmerId: 'farmer-1',
      veterinarianId: veterinarianId,
      animalId: animalId,
      appointmentDate: appointmentDate,
      appointmentTime: appointmentTime,
      visitType: visitType,
      reason: reason,
      status: AppointmentStatus.pending,
    );
    mockAppointments.add(app);
    return app;
  }

  @override
  Future<AppointmentModel> confirmAppointment(String id) async => throw UnimplementedError();

  @override
  Future<AppointmentModel> rejectAppointment(String id, {String? reason}) async => throw UnimplementedError();

  @override
  Future<AppointmentModel> completeAppointment(String id, {String? notes}) async => throw UnimplementedError();

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
  Future<List<dynamic>> getMessages(String appointmentId) async =>
      mockMessages[appointmentId] ?? [];

  @override
  Future<Map<String, dynamic>> sendMessage({
    required String appointmentId,
    required String content,
    String? messageType,
    String? treatmentPayloadJson,
  }) async {
    final msg = {
      'id': 'msg-${DateTime.now().millisecondsSinceEpoch}',
      'appointmentId': appointmentId,
      'senderId': 'user-vet-1',
      'senderName': 'Dr. Sarah Jenkins',
      'senderRole': 'VETERINARIAN',
      'recipientId': 'user-farmer-1',
      'messageType': messageType ?? 'TEXT',
      'content': content,
      'treatmentPayloadJson': treatmentPayloadJson,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };
    final list = mockMessages[appointmentId] ?? [];
    mockMessages[appointmentId] = [...list, msg];
    return {'data': msg};
  }
}

class MockTestAuthRepository implements AuthRepository {
  @override
  Future<String> uploadProfilePhoto(String filePath) async => '';
  @override
  Future<void> deleteProfilePhoto() async {}
  UserModel? mockUser;
  List<Map<String, dynamic>> mockVets = [];

  @override
  Future<UserModel?> restoreSession() async => mockUser;

  @override
  Future<UserModel?> getCachedUser() async => mockUser;

  @override
  Future<List<Map<String, dynamic>>> listVets({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? village,
    String? taluka,
    String? district,
  }) async => mockVets;

  @override
  Future<UserModel> loginFarmer({required String identifier, required String password}) async => throw UnimplementedError();

  @override
  Future<UserModel> loginVet({required String email, required String password}) async => mockUser!;

  @override
  Future<void> logout() async {}

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
  Future<UserModel> updateProfile({String? fullName, String? phone, String? farmName, String? village, String? taluka, String? district, String? state, double? latitude, double? longitude, String? clinicName, String? clinicAddress, String? specialization, String? qualification, int? yearsExperience, bool? isAvailable, bool? emergencyAvailable, String? shiftSchedule, String? profilePhotoUrl, String? certificateUrl}) async => mockUser!;

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {}
}

Widget _wrapWithLocalizations(Widget child) {
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
  late MockTestAnimalRepository mockAnimalRepo;
  late MockTestAppointmentRepository mockAppointmentRepo;
  late MockTestAuthRepository mockAuthRepo;

  setUp(() {
    mockAnimalRepo = MockTestAnimalRepository();
    mockAppointmentRepo = MockTestAppointmentRepository();
    mockAuthRepo = MockTestAuthRepository();

    animalNotifier.setRepository(mockAnimalRepo);
    appointmentNotifier.setRepository(mockAppointmentRepo);

    mockAuthRepo.mockUser = const UserModel(
      id: 'user-vet-1',
      name: 'Dr. Sarah Jenkins',
      emailOrPhone: 'sarah@vetra.gov.in',
      role: UserRole.veterinarian,
      metadata: {
        'qualification': 'BVSc & AH, MVSc',
        'specialization': 'Bovine Medicine',
        'clinicName': 'District Veterinary Hospital',
        'clinicAddress': '12 Animal Welfare Marg, Pune',
        'verificationStatus': 'VERIFIED',
      },
    );

    mockAuthRepo.mockVets = [
      {
        'id': 'vet-1',
        'fullName': 'Dr. Sarah Jenkins',
        'clinicName': 'District Veterinary Hospital',
        'clinicAddress': '12 Animal Welfare Marg, Pune',
        'qualification': 'BVSc & AH',
        'specialization': 'Large Animal Surgery',
        'isAvailable': true,
        'verificationStatus': 'VERIFIED',
      },
      {
        'id': 'vet-2',
        'fullName': 'Dr. Rajesh Patil',
        'clinicName': 'Patil Veterinary Clinic',
        'clinicAddress': '45 Rural Road, Baramati',
        'qualification': 'MVSc Pathology',
        'specialization': 'Epidemiology',
        'isAvailable': true,
        'verificationStatus': 'VERIFIED',
      },
    ];

    authNotifier.setRepository(mockAuthRepo);
    authNotifier.setCurrentUser(mockAuthRepo.mockUser);
    authNotifier.setVetsList(mockAuthRepo.mockVets);
  });

  testWidgets('AppointmentBookingPage allows switching veterinarians dynamically', (tester) async {
    mockAnimalRepo.mockAnimals = [
      AnimalModel(
        id: 'animal-1',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh Farmer',
        tagNumber: 'MH-10293',
        animalName: 'Gauri Cow',
        species: 'Cattle',
        breed: 'Gir',
        gender: 'FEMALE',
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ];
    await animalNotifier.loadAnimals();

    await tester.pumpWidget(_wrapWithLocalizations(const AppointmentBookingPage()));
    await tester.pumpAndSettle();

    // Verify initial Vet Trust Card
    expect(find.text('Switch Veterinarian'), findsOneWidget);

    // Tap switch veterinarian button
    await tester.tap(find.text('Switch Veterinarian'));
    await tester.pumpAndSettle();

    // Modal sheet opens with available vets
    expect(find.text('Choose Veterinarian'), findsOneWidget);
    expect(find.text('Dr. Rajesh Patil'), findsOneWidget);

    // Select Dr. Rajesh Patil
    await tester.tap(find.text('Dr. Rajesh Patil'));
    await tester.pumpAndSettle();

    // Verify Vet Trust Card updated to Dr. Rajesh Patil
    expect(find.text('Dr. Rajesh Patil'), findsOneWidget);
  });

  testWidgets('AppointmentChatPage displays consultation messages and official Rx instructions', (tester) async {
    mockAppointmentRepo.mockAppointments = [
      AppointmentModel(
        id: 'appt-100',
        farmerId: 'farmer-1',
        farmerName: 'Ramesh Farmer',
        veterinarianId: 'user-vet-1',
        veterinarianName: 'Dr. Sarah Jenkins',
        animalId: 'animal-1',
        animalName: 'Gauri Cow',
        tagNumber: 'MH-10293',
        species: 'Cattle',
        appointmentDate: '2026-08-30',
        appointmentTime: '10:00 AM',
        visitType: VisitType.generalCheckup,
        reason: 'Mastitis suspected',
        status: AppointmentStatus.confirmed,
      ),
    ];

    mockAppointmentRepo.mockMessages['appt-100'] = [
      {
        'id': 'msg-1',
        'appointmentId': 'appt-100',
        'senderId': 'farmer-1',
        'senderName': 'Ramesh Farmer',
        'senderRole': 'FARMER',
        'recipientId': 'user-vet-1',
        'messageType': 'TEXT',
        'content': 'Doctor, the cow has reduced milk yield and swollen udder.',
        'isRead': true,
        'createdAt': '2026-08-28T10:00:00Z',
      },
      {
        'id': 'msg-2',
        'appointmentId': 'appt-100',
        'senderId': 'user-vet-1',
        'senderName': 'Dr. Sarah Jenkins',
        'senderRole': 'VETERINARIAN',
        'recipientId': 'farmer-1',
        'messageType': 'TREATMENT_INSTRUCTION',
        'content': 'Treatment Instructions: Acute Mastitis - Keep dry and isolate',
        'treatmentPayloadJson': '{"diagnosis":"Acute Mastitis","medication":"Intramammary Ceftiofur & Flunixin","dosage":"Apply 1 tube daily after complete milking for 3 days","careInstructions":"Keep bedding clean and dry, isolate from herd","followUp":"Re-evaluate somatic cell count after 5 days"}',
        'isRead': false,
        'createdAt': '2026-08-28T10:15:00Z',
      },
    ];

    await tester.pumpWidget(_wrapWithLocalizations(const AppointmentChatPage(appointmentId: 'appt-100')));
    await tester.pumpAndSettle();

    // Verify consultation messages render
    expect(find.text('Doctor, the cow has reduced milk yield and swollen udder.'), findsOneWidget);

    // Verify official treatment Rx card renders
    expect(find.text('OFFICIAL TREATMENT INSTRUCTION'), findsOneWidget);
    expect(find.text('Acute Mastitis'), findsOneWidget);
    expect(find.text('Intramammary Ceftiofur & Flunixin'), findsOneWidget);
    expect(find.text('Apply 1 tube daily after complete milking for 3 days'), findsOneWidget);
  });

  testWidgets('AnimalTimelinePage displays real vaccination records and certificate attachment', (tester) async {
    mockAnimalRepo.mockRecords['animal-1'] = [
      AnimalHealthRecordModel(
        id: 'rec-1',
        animalId: 'animal-1',
        recordType: 'VACCINATION',
        source: 'VETERINARIAN',
        title: 'FMD Quadrivalent Booster',
        vaccineName: 'Raksha-Ovac FMD',
        batchNumber: 'FMD-2026-9081',
        nextDueDate: '2027-02-28',
        documentUrl: 'https://vetra.gov.in/certs/fmd-cert-9081.pdf',
        veterinarianName: 'Dr. Sarah Jenkins',
        recordedAt: '2026-08-28T09:00:00Z',
      ),
    ];
    animalNotifier.setSelectedAnimalId('animal-1');

    await tester.pumpWidget(_wrapWithLocalizations(const AnimalTimelinePage(animalId: 'animal-1')));
    await tester.pumpAndSettle();

    // Verify vaccine title, batch, next due date, and document certificate
    expect(find.text('FMD Quadrivalent Booster'), findsOneWidget);
    expect(find.text('Batch: FMD-2026-9081'), findsOneWidget);
    expect(find.text('Next Due: 2027-02-28'), findsOneWidget);
    expect(find.text('View Attached Certificate / Document'), findsOneWidget);
  });
}
