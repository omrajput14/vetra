// The screens that used to show invented data now show, and save, the real thing.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vetra/core/design_system/buttons/primary_button.dart';
import 'package:vetra/core/network/network_exceptions.dart';
import 'package:vetra/features/animal/data/models/animal_dto.dart';
import 'package:vetra/features/animal/data/models/animal_health_record_dto.dart';
import 'package:vetra/features/animal/domain/repositories/animal_repository.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/features/auth/domain/repositories/auth_repository.dart';
import 'package:vetra/features/auth/presentation/providers/auth_provider.dart';
import 'package:vetra/features/medical/presentation/pages/add_prescription_page.dart';
import 'package:vetra/features/medical/presentation/pages/add_treatment_page.dart';
import 'package:vetra/features/medical/presentation/pages/deworming_record_page.dart';
import 'package:vetra/features/medical/presentation/pages/vaccination_details_page.dart';
import 'package:vetra/features/medical/presentation/pages/vaccination_schedule_page.dart';
import 'package:vetra/features/settings/presentation/pages/security_page.dart';
import 'package:vetra/features/shared/presentation/pages/search_results_page.dart';

AnimalModel _animal(String id, String name, String tag, String species, String breed) => AnimalModel(
      id: id, farmerId: 'f1', farmerName: 'Sunil Patil', animalName: name, tagNumber: tag,
      species: species, breed: breed, gender: 'FEMALE', createdAt: '', updatedAt: '',
    );

AnimalHealthRecordModel _record(String type, String title,
        {String? treatment, String? vaccineName, String? nextDueDate, String? batchNumber, String? vet}) =>
    AnimalHealthRecordModel(
      id: title, animalId: 'x', recordType: type, source: 'VETERINARIAN', title: title, treatment: treatment,
      vaccineName: vaccineName, nextDueDate: nextDueDate, batchNumber: batchNumber, veterinarianName: vet,
      recordedAt: '2026-05-15T10:00:00',
    );

class _Animals extends Fake implements AnimalRepository {
  List<AnimalModel> animals = [];
  List<AnimalHealthRecordModel> records = [];
  final created = <Map<String, dynamic>>[];
  Object? createError;

  @override
  Future<List<AnimalModel>> listAnimals() async => animals;
  @override
  Future<List<AnimalHealthRecordModel>> getAnimalHealthRecords(String animalId) async => records;
  @override
  Future<AnimalHealthStatusModel> getLatestHealthStatus(String animalId) async =>
      AnimalHealthStatusModel(animalId: animalId, status: 'HEALTHY', statusSummary: 'Healthy');
  @override
  Future<AnimalHealthRecordModel> createHealthRecord(String animalId, Map<String, dynamic> body) async {
    if (createError != null) throw createError!;
    created.add(body);
    return AnimalHealthRecordModel.fromJson({...body, 'id': 'new', 'animalId': animalId});
  }
}

class _Auth extends Fake implements AuthRepository {
  final changes = <(String, String)>[];
  Object? changeError;
  int logouts = 0;

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    if (changeError != null) throw changeError!;
    changes.add((currentPassword, newPassword));
  }

  @override
  Future<void> logout() async => logouts++;
}

/// Opens [page] on top of a home route so the page can pop back.
Future<void> _open(WidgetTester tester, Widget page) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => const Scaffold(body: Text('HOME'))),
    GoRoute(path: '/page', builder: (_, __) => page),
    GoRoute(path: '/welcome', builder: (_, __) => const Scaffold(body: Text('WELCOME'))),
  ]);
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  router.push('/page');
  await tester.pumpAndSettle();
}

void main() {
  late _Animals repo;
  setUp(() {
    repo = _Animals();
    animalNotifier.setRepository(repo);
  });

  testWidgets('Search matches the user\'s own animals by breed and says when nothing matches', (t) async {
    repo.animals = [
      _animal('a1', 'Kapila', 'MH12-4521', 'CATTLE', 'Gir'),
      _animal('a2', 'Gauri', 'MH12-9001', 'BUFFALO', 'Murrah'),
    ];
    await animalNotifier.loadAnimals();
    await _open(t, const SearchResultsPage(query: 'gir'));
    expect(find.text('Kapila (MH12-4521)'), findsOneWidget);
    expect(find.text('Gauri (MH12-9001)'), findsNothing);

    await _open(t, const SearchResultsPage(query: 'zebu'));
    expect(find.text('No animals match "zebu".'), findsOneWidget);
  });

  testWidgets('Vaccination schedule lists only vaccinations, with the next due date', (t) async {
    repo.records = [
      _record('VACCINATION', 'FMD', vaccineName: 'FMD Vaccine', nextDueDate: '2026-11-15'),
      _record('TREATMENT', 'Wound dressing'),
    ];
    await _open(t, const VaccinationSchedulePage(animalId: 'vac-1'));
    expect(find.text('FMD Vaccine'), findsOneWidget);
    expect(find.textContaining('Next due 15 Nov 2026'), findsOneWidget);
    expect(find.text('Wound dressing'), findsNothing);
  });

  testWidgets('Vaccination schedule says so when the animal has none', (t) async {
    await _open(t, const VaccinationSchedulePage(animalId: 'vac-empty'));
    expect(find.text('No vaccinations recorded for this animal yet.'), findsOneWidget);
  });

  testWidgets('Vaccination details show the record\'s own fields and leave missing ones out', (t) async {
    await _open(t, VaccinationDetailsPage(
      record: _record('VACCINATION', 'LSD', vaccineName: 'Lumpi-ProVac', batchNumber: 'B-77', vet: 'Dr. Anjali Deshmukh'),
    ));
    expect(find.text('Lumpi-ProVac'), findsOneWidget);
    expect(find.text('Batch number: B-77'), findsOneWidget);
    expect(find.text('Administered by: Dr. Anjali Deshmukh'), findsOneWidget);
    expect(find.textContaining('Next due'), findsNothing);

    await _open(t, const VaccinationDetailsPage());
    expect(find.text('Vaccination record not found.'), findsOneWidget);
  });

  testWidgets('Deworming history picks deworming treatments out of the timeline', (t) async {
    repo.records = [
      _record('TREATMENT', 'Albendazole drench', treatment: '10 ml oral'),
      _record('TREATMENT', 'Wound dressing', treatment: 'Antiseptic'),
    ];
    await _open(t, const DewormingRecordPage(animalId: 'dw-1'));
    expect(find.text('Albendazole drench'), findsOneWidget);
    expect(find.text('Wound dressing'), findsNothing);
  });

  testWidgets('Add Prescription saves a TREATMENT record and returns', (t) async {
    await _open(t, const AddPrescriptionPage(animalId: 'rx-1'));
    await t.enterText(find.byType(TextField).at(0), 'Oxytet 200 LA');
    await t.enterText(find.byType(TextField).at(1), '10ml IM daily');
    await t.enterText(find.byType(TextField).at(2), '5');
    await t.tap(find.text('Save Prescription'));
    await t.pumpAndSettle();
    expect(repo.created.single, {
      'recordType': 'TREATMENT',
      'title': 'Prescription: Oxytet 200 LA',
      'treatment': '10ml IM daily for 5 days',
    });
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Add Prescription shows the server\'s reason and stays open when saving fails', (t) async {
    repo.createError = NetworkException('Animal not found with ID: rx-2', statusCode: 404);
    await _open(t, const AddPrescriptionPage(animalId: 'rx-2'));
    await t.enterText(find.byType(TextField).at(0), 'Oxytet');
    await t.enterText(find.byType(TextField).at(1), '10ml');
    await t.tap(find.text('Save Prescription'));
    await t.pumpAndSettle();
    expect(find.text('Animal not found with ID: rx-2'), findsOneWidget);
    expect(find.text('HOME'), findsNothing);
  });

  testWidgets('Record Treatment saves a TREATMENT record', (t) async {
    await _open(t, const AddTreatmentPage(animalId: 'tx-1'));
    await t.enterText(find.byType(TextField), 'Wound dressing and antiseptic injection');
    await t.tap(find.text('Submit Record'));
    await t.pumpAndSettle();
    expect(repo.created.single['treatment'], 'Wound dressing and antiseptic injection');
    expect(repo.created.single['recordType'], 'TREATMENT');
  });

  group('Change password', () {
    late _Auth auth;
    setUp(() {
      auth = _Auth();
      authNotifier.setRepository(auth);
    });

    Future<void> fill(WidgetTester t, String current, String next, String confirm) async {
      await _open(t, const SecurityPage());
      await t.enterText(find.byType(TextField).at(0), current);
      await t.enterText(find.byType(TextField).at(1), next);
      await t.enterText(find.byType(TextField).at(2), confirm);
      await t.tap(find.widgetWithText(PrimaryButton, 'Change Password'));
      await t.pumpAndSettle();
    }

    testWidgets('mismatched confirmation is caught before calling the server', (t) async {
      await fill(t, 'Farmer@123', 'NewPass@1', 'NewPass@2');
      expect(find.text('New passwords do not match.'), findsOneWidget);
      expect(auth.changes, isEmpty);
    });

    testWidgets('a wrong current password shows the server\'s reason and keeps the user signed in', (t) async {
      auth.changeError = NetworkException('Current password does not match', statusCode: 403);
      await fill(t, 'wrong', 'NewPass@1', 'NewPass@1');
      expect(find.text('Current password does not match'), findsOneWidget);
      expect(auth.logouts, 0);
    });

    testWidgets('success sends both passwords, signs out and returns to Welcome', (t) async {
      await fill(t, 'Farmer@123', 'NewPass@1', 'NewPass@1');
      expect(auth.changes, [('Farmer@123', 'NewPass@1')]);
      expect(auth.logouts, 1);
      expect(find.text('WELCOME'), findsOneWidget);
    });
  });
}
