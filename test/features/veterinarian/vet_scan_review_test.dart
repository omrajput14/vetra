// Vet reviews farmers' AI scans: approve (confirmed case) or reject (with a reason).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:vetra/core/models/user_role.dart';
import 'package:vetra/core/network/network_exceptions.dart';
import 'package:vetra/features/ai/data/api/ai_scan_api_service.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';
import 'package:vetra/features/ai/presentation/pages/scan_history_page.dart';
import 'package:vetra/features/veterinarian/presentation/pages/vet_scan_review_page.dart';

AIScanModel _scan(String id, String status, {String? notes, String? vet, String? para, String? reason}) => AIScanModel(
      id: id, animalId: 'a1', animalName: 'Kapila', imageUrl: '', status: status,
      diagnosis: 'Lumpy Skin Disease', confidenceScore: 0.82, uploadedByUserName: 'Sunil Patil',
      notes: notes, verifiedByVetName: vet, createdAt: '2026-09-25T04:09:00Z',
      triagedByName: para, triageNotes: para == null ? null : 'Nodules on neck', reviewNotes: reason,
    );

class _FakeApi extends Fake implements AIScanApiService {
  List<AIScanModel> page = [];
  final approved = <Map<String, String?>>[];
  final rejected = <(String, String)>[];
  final escalated = <(String, String?)>[];
  Object? error;

  @override
  Future<AIScanModel> escalateScan(String scanId, {String? notes}) async {
    escalated.add((scanId, notes));
    return _scan(scanId, 'ESCALATED', para: 'Ganesh Kale');
  }

  @override
  Future<List<AIScanModel>> listScansPage({int page = 0, int size = 10}) async => page == 0 ? this.page : [];

  @override
  Future<AIScanModel> approveScan(String scanId, {String? treatmentNotes, String? customDiagnosis}) async {
    if (error != null) throw error!;
    approved.add({'id': scanId, 'treatmentNotes': treatmentNotes, 'customDiagnosis': customDiagnosis});
    return _scan(scanId, 'VERIFIED');
  }

  @override
  Future<AIScanModel> rejectScan(String scanId, String reason) async {
    if (error != null) throw error!;
    rejected.add((scanId, reason));
    return _scan(scanId, 'REJECTED', notes: 'REJECTED: $reason');
  }
}

Future<void> _pumpQueue(WidgetTester t, _FakeApi api, {bool paraVet = false}) async {
  t.view.physicalSize = const Size(1080, 2400);
  t.view.devicePixelRatio = 1.0;
  addTearDown(t.view.reset);
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (_, __) => VetScanReviewListPage(api: api, paraVet: paraVet)),
    GoRoute(
      path: '/vet-scan-review',
      builder: (_, s) => VetScanReviewDetailPage(scan: s.extra as AIScanModel, api: api, paraVet: paraVet),
    ),
  ]);
  await t.pumpWidget(MaterialApp.router(routerConfig: router));
  await t.pumpAndSettle();
}

void main() {
  test('rejection reason is read from the backend\'s "REJECTED: ..." notes', () {
    expect(_scan('x', 'REJECTED', notes: 'REJECTED: skin lesions are ringworm').rejectionReason,
        'skin lesions are ringworm');
    expect(_scan('x', 'COMPLETED', notes: '{"severity":"HIGH"}').rejectionReason, isNull);
    expect(_scan('x', 'COMPLETED').awaitingVetReview, isTrue);
    expect(_scan('x', 'VERIFIED').awaitingVetReview, isFalse);
    // The backend sends the account email/phone as the "name"; never show it.
    expect(_scan('x', 'VERIFIED', vet: 'pipe.vet@vetra.test').vetDisplayName, isNull);
    expect(_scan('x', 'VERIFIED', vet: '+91 9876543210').vetDisplayName, isNull);
    expect(_scan('x', 'VERIFIED', vet: 'Dr. Anjali Deshmukh').vetDisplayName, 'Dr. Anjali Deshmukh');
  });

  testWidgets('queue lists only scans still awaiting a vet', (t) async {
    final api = _FakeApi()..page = [_scan('s1', 'COMPLETED'), _scan('s2', 'VERIFIED'), _scan('s3', 'REJECTED')];
    await _pumpQueue(t, api);
    expect(find.textContaining('Lumpy Skin Disease (82%)'), findsOneWidget);
  });

  testWidgets('approve sends the vet\'s advice as treatment notes and leaves the queue', (t) async {
    final api = _FakeApi()..page = [_scan('s1', 'COMPLETED')];
    await _pumpQueue(t, api);
    await t.tap(find.textContaining('Lumpy Skin Disease (82%)'));
    await t.pumpAndSettle();
    await t.enterText(find.widgetWithText(TextField, 'Treatment advice for the farmer (optional)'), 'Isolate; LSD vaccine for herd');
    await t.tap(find.text('Approve'));
    await t.pumpAndSettle();

    expect(api.approved.single, {'id': 's1', 'treatmentNotes': 'Isolate; LSD vaccine for herd', 'customDiagnosis': ''});
    expect(find.text('No scans waiting for review.'), findsOneWidget);
  });

  testWidgets('reject needs a reason; cancelling sends nothing', (t) async {
    final api = _FakeApi()..page = [_scan('s1', 'COMPLETED')];
    await _pumpQueue(t, api);
    await t.tap(find.textContaining('Lumpy Skin Disease (82%)'));
    await t.pumpAndSettle();

    await t.tap(find.text('Reject'));
    await t.pumpAndSettle();
    await t.tap(find.text('Cancel'));
    await t.pumpAndSettle();
    expect(api.rejected, isEmpty);

    await t.tap(find.text('Reject'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, 'Lesions are ringworm, not LSD');
    await t.tap(find.widgetWithText(TextButton, 'Reject'));
    await t.pumpAndSettle();
    expect(api.rejected.single, ('s1', 'Lesions are ringworm, not LSD'));
  });

  testWidgets('a server refusal is shown and the scan stays in review', (t) async {
    final api = _FakeApi()
      ..page = [_scan('s1', 'COMPLETED')]
      ..error = NetworkException('AI Diagnostic scan has already been reviewed', statusCode: 422);
    await _pumpQueue(t, api);
    await t.tap(find.textContaining('Lumpy Skin Disease (82%)'));
    await t.pumpAndSettle();
    await t.tap(find.text('Approve'));
    await t.pumpAndSettle();
    expect(find.text('AI Diagnostic scan has already been reviewed'), findsOneWidget);
    expect(find.text('Review AI Scan'), findsOneWidget);
  });

  testWidgets('farmer\'s Scan History shows the vet\'s decision', (t) async {
    await t.pumpWidget(MaterialApp(
      home: ScanHistoryPage(
        loadServer: () async => [
          _scan('a', 'VERIFIED', vet: 'Dr. Anjali Deshmukh'),
          _scan('b', 'REJECTED', vet: 'Dr. Anjali Deshmukh', notes: 'REJECTED: ringworm'),
          _scan('c', 'COMPLETED'),
        ],
        loadLocal: () async => [],
      ),
    ));
    await t.pumpAndSettle();
    expect(find.textContaining('Confirmed by Dr. Anjali Deshmukh'), findsOneWidget);
    expect(find.textContaining('Not confirmed by Dr. Anjali Deshmukh'), findsOneWidget);
    expect(find.textContaining('Awaiting vet review'), findsOneWidget);
  });

  test('para-vet role and triage helpers', () {
    expect(UserRole.fromApi('PARA_VET'), UserRole.paraVet);
    expect(UserRole.fromApi('VETERINARIAN'), UserRole.veterinarian);
    expect(UserRole.fromApi(null), UserRole.farmer);
    expect(_scan('x', 'ESCALATED').awaitingVetReview, isTrue);
    expect(_scan('x', 'ESCALATED').awaitingParaVet, isFalse);
    expect(_scan('x', 'REJECTED', reason: 'Ringworm').rejectionReason, 'Ringworm');
  });

  testWidgets('para-vet sends a scan to a vet with field notes', (t) async {
    final api = _FakeApi()..page = [_scan('s1', 'COMPLETED'), _scan('s2', 'ESCALATED', para: 'Ganesh Kale')];
    await _pumpQueue(t, api, paraVet: true);
    expect(find.text('Scans to Check'), findsOneWidget);
    expect(find.textContaining('Lumpy Skin Disease (82%)'), findsOneWidget); // escalated one is not theirs any more
    await t.tap(find.textContaining('Lumpy Skin Disease (82%)'));
    await t.pumpAndSettle();
    expect(find.text('Approve'), findsNothing);
    await t.enterText(find.widgetWithText(TextField, 'What you saw at the farm (optional)'), 'Fever 40.5C, nodules');
    await t.tap(find.text('Send to vet'));
    await t.pumpAndSettle();
    expect(api.escalated.single, ('s1', 'Fever 40.5C, nodules'));
    expect(find.text('No scans waiting for review.'), findsOneWidget);
  });

  testWidgets('vet queue shows para-vet escalations first', (t) async {
    final api = _FakeApi()..page = [_scan('s1', 'COMPLETED'), _scan('s2', 'ESCALATED', para: 'Ganesh Kale')];
    await _pumpQueue(t, api);
    final tiles = t.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(((tiles.first.subtitle as Text).data ?? ''), startsWith('Escalated by Ganesh Kale: Nodules on neck'));
  });
}
