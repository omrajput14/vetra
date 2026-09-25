// Para-vet home (approval gate) and recording vaccination doses in a drive.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vetra/features/paravet/presentation/paravet_pages.dart';

class _FakeApi extends Fake implements ParaVetApi {
  String status = 'PENDING';
  final recorded = <List<String>>[];

  @override
  Future<String> approvalStatus() async => status;

  @override
  Future<List<DriveAnimal>> animals(String driveId) async => [
        DriveAnimal.fromJson({'animalId': 'a1', 'animalName': 'Kapila', 'tagNumber': 'MH12-1', 'farmerName': 'Sunil Patil'}),
        DriveAnimal.fromJson({'animalId': 'a2', 'animalName': 'Gauri', 'tagNumber': 'MH12-2', 'farmerName': 'Sunil Patil'}),
      ];

  @override
  Future<int> recordDoses(String driveId, List<String> animalIds) async {
    recorded.add(animalIds);
    return 10 + animalIds.length;
  }
}

Future<void> _pump(WidgetTester t, Widget page) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  final router = GoRouter(routes: [GoRoute(path: '/', builder: (_, __) => page)]);
  await t.pumpWidget(MaterialApp.router(routerConfig: router));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('unapproved para-vet sees "Waiting for approval", not the jobs', (t) async {
    await _pump(t, ParaVetHomePage(api: _FakeApi()));
    expect(find.text('Waiting for approval'), findsOneWidget);
    expect(find.text('Scans to check'), findsNothing);
  });

  testWidgets('approved para-vet sees scans and vaccination drives', (t) async {
    await _pump(t, ParaVetHomePage(api: _FakeApi()..status = 'VERIFIED'));
    expect(find.text('Scans to check'), findsOneWidget);
    expect(find.text('Vaccination drives'), findsOneWidget);
  });

  testWidgets('ticking animals records one dose each and updates the count', (t) async {
    final api = _FakeApi();
    final drive = ParaVetDrive.fromJson({
      'id': 'c1', 'campaignName': 'LSD ring vaccination - Pune', 'diseaseName': 'Lumpy Skin Disease',
      'status': 'ACTIVE', 'plannedDoses': 500, 'administeredDoses': 10,
    });
    await _pump(t, ParaVetDriveDetailPage(drive: drive, api: api));
    expect(find.text('10 of 500 doses given'), findsOneWidget);
    await t.tap(find.textContaining('Kapila'));
    await t.tap(find.textContaining('Gauri'));
    await t.pump();
    await t.tap(find.text('Record 2 dose(s)'));
    await t.pumpAndSettle();
    expect(api.recorded.single, ['a1', 'a2']);
    expect(find.text('12 of 500 doses given'), findsOneWidget);
    expect(find.text('Every animal in this area has had its dose.'), findsOneWidget);
  });
}
