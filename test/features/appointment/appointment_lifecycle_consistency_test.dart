import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/models/user_model.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/features/appointment/data/models/appointment_dto.dart';
import 'package:vetra/features/appointment/domain/repositories/appointment_repository.dart';
import 'package:vetra/features/appointment/presentation/providers/appointment_provider.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/features/shared/presentation/pages/appointment_details_page.dart';
import 'package:vetra/l10n/app_localizations.dart';

AppointmentModel copyWithStatus(AppointmentModel base, AppointmentStatus newStatus, {String? notes}) {
  return AppointmentModel(
    id: base.id,
    farmerId: base.farmerId,
    farmerName: base.farmerName,
    farmerPhone: base.farmerPhone,
    veterinarianId: base.veterinarianId,
    veterinarianName: base.veterinarianName,
    clinicName: base.clinicName,
    animalId: base.animalId,
    animalName: base.animalName,
    tagNumber: base.tagNumber,
    species: base.species,
    appointmentDate: base.appointmentDate,
    appointmentTime: base.appointmentTime,
    visitType: base.visitType,
    reason: base.reason,
    status: newStatus,
    veterinarianNotes: notes ?? base.veterinarianNotes,
    cancellationReason: base.cancellationReason,
    vetLatitude: base.vetLatitude,
    vetLongitude: base.vetLongitude,
    vetLocationUpdatedAt: base.vetLocationUpdatedAt,
    version: base.version,
    createdAt: base.createdAt,
    updatedAt: base.updatedAt,
  );
}

class MockAppointmentRepository implements AppointmentRepository {
  final Map<String, AppointmentModel> storage = {};
  int getAppointmentByIdCalls = 0;

  @override
  Future<List<AppointmentModel>> listAppointments() async {
    return storage.values.toList();
  }

  @override
  Future<AppointmentModel> getAppointmentById(String id) async {
    getAppointmentByIdCalls++;
    if (storage.containsKey(id)) {
      return storage[id]!;
    }
    throw Exception('Appointment not found');
  }

  @override
  Future<AppointmentModel> confirmAppointment(String id) async {
    final existing = storage[id]!;
    final updated = copyWithStatus(existing, AppointmentStatus.confirmed);
    storage[id] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> completeAppointment(String id, {String? notes}) async {
    final existing = storage[id]!;
    final updated = copyWithStatus(existing, AppointmentStatus.completed, notes: notes ?? 'Checkup complete');
    storage[id] = updated;
    return updated;
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id, {String? reason}) async => throw UnimplementedError();
  @override
  Future<AppointmentModel> createAppointment({
    required String animalId,
    required String veterinarianId,
    required String appointmentDate,
    required String appointmentTime,
    required VisitType visitType,
    required String reason,
  }) async => throw UnimplementedError();

  @override
  Future<AppointmentLiveLocationDto> getLiveLocation(String id) async {
    return AppointmentLiveLocationDto(isLive: false);
  }

  @override
  Future<AppointmentLiveLocationDto> updateLocation(String id, double latitude, double longitude, {double? accuracy}) async {
    return AppointmentLiveLocationDto(isLive: true, latitude: latitude, longitude: longitude);
  }

  @override
  Future<List<dynamic>> getMessages(String appointmentId) async => [];
  @override
  Future<AppointmentModel> markArrived(String id) async => throw UnimplementedError();
  @override
  Future<AppointmentModel> rejectAppointment(String id, {String? reason}) async => throw UnimplementedError();
  @override
  Future<Map<String, dynamic>> sendMessage({
    required String appointmentId,
    required String content,
    String? messageType,
    String? treatmentPayloadJson,
  }) async => throw UnimplementedError();
  @override
  Future<AppointmentModel> startEnRoute(String id) async => throw UnimplementedError();
}

Widget createTestWidget({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

void main() {
  late MockAppointmentRepository mockRepo;

  setUp(() {
    mockRepo = MockAppointmentRepository();
    appointmentNotifier.setRepository(mockRepo);
    appointmentNotifier.clearSelectedAppointment();
  });

  void setLargeViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  final completedAppointment = AppointmentModel(
    id: 'appt-completed-1',
    farmerId: 'farmer-1',
    farmerName: 'Ramesh Patel',
    farmerPhone: '+91 98765 43210',
    veterinarianId: 'vet-1',
    veterinarianName: 'Dr. Sharma',
    animalId: 'animal-loki',
    animalName: 'Loki',
    tagNumber: 'TAG-LOKI-99',
    species: 'Cattle',
    appointmentDate: '2026-09-10',
    appointmentTime: '10:00:00',
    visitType: VisitType.generalCheckup,
    status: AppointmentStatus.completed,
    reason: 'Follow-up checkup',
    veterinarianNotes: 'Animal is in excellent health.',
    createdAt: '2026-09-10T09:00:00Z',
    updatedAt: '2026-09-10T11:00:00Z',
  );

  final pendingAppointment = AppointmentModel(
    id: 'appt-pending-2',
    farmerId: 'farmer-1',
    farmerName: 'Ramesh Patel',
    farmerPhone: '+91 98765 43210',
    veterinarianId: 'vet-1',
    veterinarianName: 'Dr. Sharma',
    animalId: 'animal-bella',
    animalName: 'Bella',
    tagNumber: 'TAG-BELLA-11',
    species: 'Cattle',
    appointmentDate: '2026-09-11',
    appointmentTime: '14:00:00',
    visitType: VisitType.generalCheckup,
    status: AppointmentStatus.pending,
    reason: 'Routine consultation',
    createdAt: '2026-09-10T09:00:00Z',
    updatedAt: '2026-09-10T09:00:00Z',
  );

  testWidgets('1 & 2. Completed appointment initially loads and displays Status: Completed', (tester) async {
    mockRepo.storage['appt-completed-1'] = completedAppointment;
    authNotifier.setCurrentUser(const UserModel(
      id: 'vet-1',
      name: 'Dr. Sharma',
      emailOrPhone: 'vet@vetra.app',
      role: UserRole.veterinarian,
    ));

    setLargeViewport(tester);
    await tester.pumpWidget(
      createTestWidget(child: const AppointmentDetailsPage(appointmentId: 'appt-completed-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Appointment Details'), findsOneWidget);
    expect(find.text('Status: Completed'), findsOneWidget);
    expect(find.text('Animal Details'), findsOneWidget);
    expect(find.textContaining('Loki'), findsOneWidget);
    expect(find.text('Veterinarian Consultation Notes'), findsOneWidget);
    expect(find.text('Animal is in excellent health.'), findsOneWidget);
  });

  testWidgets('3 & 4. Accept Request and Reject buttons are NOT rendered for COMPLETED appointment', (tester) async {
    mockRepo.storage['appt-completed-1'] = completedAppointment;
    authNotifier.setCurrentUser(const UserModel(
      id: 'vet-1',
      name: 'Dr. Sharma',
      emailOrPhone: 'vet@vetra.app',
      role: UserRole.veterinarian,
    ));

    setLargeViewport(tester);
    await tester.pumpWidget(
      createTestWidget(child: const AppointmentDetailsPage(appointmentId: 'appt-completed-1')),
    );
    await tester.pumpAndSettle();

    // Verify Accept Request and Reject buttons are not rendered
    expect(find.text('Accept Request'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('Pending appointment displays Status: Pending and shows Accept/Reject for Vet', (tester) async {
    mockRepo.storage['appt-pending-2'] = pendingAppointment;
    authNotifier.setCurrentUser(const UserModel(
      id: 'vet-1',
      name: 'Dr. Sharma',
      emailOrPhone: 'vet@vetra.app',
      role: UserRole.veterinarian,
    ));

    setLargeViewport(tester);
    await tester.pumpWidget(
      createTestWidget(child: const AppointmentDetailsPage(appointmentId: 'appt-pending-2')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Pending'), findsOneWidget);
    expect(find.text('Accept Request'), findsOneWidget);
    expect(find.text('Reject'), findsOneWidget);
  });

  testWidgets('5. A previously selected PENDING appointment cannot leak into a new detail request', (tester) async {
    mockRepo.storage['appt-pending-2'] = pendingAppointment;
    mockRepo.storage['appt-completed-1'] = completedAppointment;
    authNotifier.setCurrentUser(const UserModel(
      id: 'vet-1',
      name: 'Dr. Sharma',
      emailOrPhone: 'vet@vetra.app',
      role: UserRole.veterinarian,
    ));

    // First, select the pending appointment into the provider state
    await appointmentNotifier.getAppointmentById('appt-pending-2');
    expect(appointmentNotifier.selectedAppointment?.id, 'appt-pending-2');
    expect(appointmentNotifier.selectedAppointment?.status, AppointmentStatus.pending);

    // Now open details page for the completed appointment
    setLargeViewport(tester);
    await tester.pumpWidget(
      createTestWidget(child: const AppointmentDetailsPage(appointmentId: 'appt-completed-1')),
    );

    // During loading or immediately, the page MUST NOT render the pending appointment
    expect(find.textContaining('Bella'), findsNothing);
    expect(find.text('Status: Pending'), findsNothing);

    await tester.pumpAndSettle();

    // After load, it renders the completed appointment
    expect(find.text('Status: Completed'), findsOneWidget);
    expect(find.textContaining('Loki'), findsOneWidget);
    expect(find.text('Accept Request'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });

  testWidgets('6. Fresh backend data replaces stale local state', (tester) async {
    // Local list has stale PENDING state for appt-completed-1
    final staleLocal = copyWithStatus(completedAppointment, AppointmentStatus.pending);
    mockRepo.storage['appt-completed-1'] = completedAppointment; // Backend has authoritative COMPLETED
    authNotifier.setCurrentUser(const UserModel(
      id: 'vet-1',
      name: 'Dr. Sharma',
      emailOrPhone: 'vet@vetra.app',
      role: UserRole.veterinarian,
    ));

    // Simulate pre-existing list item with stale status
    await appointmentNotifier.getAppointmentById('appt-completed-1');
    expect(appointmentNotifier.selectedAppointment?.status, AppointmentStatus.completed);

    setLargeViewport(tester);
    await tester.pumpWidget(
      createTestWidget(child: const AppointmentDetailsPage(appointmentId: 'appt-completed-1')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Status: Completed'), findsOneWidget);
    expect(find.text('Accept Request'), findsNothing);
    expect(find.text('Reject'), findsNothing);
  });
}
