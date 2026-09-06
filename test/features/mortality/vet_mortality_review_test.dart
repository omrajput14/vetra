import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_test/flutter_test.dart";
import "package:vetra/core/localization/locale_provider.dart";
import "package:vetra/features/mortality/data/models/mortality_dto.dart";
import "package:vetra/features/mortality/domain/repositories/mortality_repository.dart";
import "package:vetra/features/mortality/presentation/pages/vet_mortality_list_page.dart";
import "package:vetra/features/mortality/presentation/pages/vet_mortality_detail_page.dart";
import "package:vetra/features/mortality/presentation/providers/mortality_provider.dart";
import "package:vetra/l10n/app_localizations.dart";

class MockVetMortalityRepository implements MortalityRepository {
  List<MortalityReportModel> pendingList = [];
  List<MortalityAuditDto> auditsList = [];
  ConfirmMortalityDto? lastConfirmDto;
  RejectMortalityDto? lastRejectDto;
  String? lastConfirmedId;
  String? lastRejectedId;

  @override
  Future<MortalityReportModel> reportMortality(CreateMortalityReportDto dto) async {
    throw UnimplementedError();
  }

  @override
  Future<MortalityReportModel> getMortalityById(String id) async {
    return pendingList.firstWhere((e) => e.id == id);
  }

  @override
  Future<MortalityReportModel> getMortalityByAnimalId(String animalId) async {
    return pendingList.firstWhere((e) => e.animalId == animalId);
  }

  @override
  Future<List<MortalityReportModel>> listFarmerMortalities({int page = 0, int size = 20}) async {
    return [];
  }

  @override
  Future<List<String>> getDiseaseCatalog() async {
    return ["Anthrax", "Foot and Mouth Disease (FMD)", "Blackleg", "Brucellosis"];
  }

  @override
  Future<List<MortalityReportModel>> getPendingMortalityCases({int page = 0, int size = 20}) async {
    return pendingList;
  }

  @override
  Future<MortalityReportModel> confirmMortality(String id, ConfirmMortalityDto dto) async {
    lastConfirmedId = id;
    lastConfirmDto = dto;
    final existing = pendingList.firstWhere((e) => e.id == id);
    return MortalityReportModel(
      id: existing.id,
      animalId: existing.animalId,
      animalName: existing.animalName,
      tagNumber: existing.tagNumber,
      farmerId: existing.farmerId,
      farmerName: existing.farmerName,
      source: existing.source,
      status: "VET_CONFIRMED",
      causeCategory: existing.causeCategory,
      causeDescription: existing.causeDescription,
      diseaseName: existing.diseaseName,
      recentlyTreated: existing.recentlyTreated,
      treatmentNotes: existing.treatmentNotes,
      notes: existing.notes,
      deathDateTime: existing.deathDateTime,
      reportedAt: existing.reportedAt,
      vetReviewedById: "vet-uuid-001",
      vetReviewedByName: "Dr. Arvind Sharma",
      vetReviewedAt: DateTime.now().toIso8601String(),
      vetCauseCategory: dto.causeCategory,
      vetDiseaseName: dto.diseaseName,
      vetClinicalNotes: dto.clinicalNotes,
      postMortemConducted: dto.postMortemConducted,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<MortalityReportModel> rejectMortality(String id, RejectMortalityDto dto) async {
    lastRejectedId = id;
    lastRejectDto = dto;
    final existing = pendingList.firstWhere((e) => e.id == id);
    return MortalityReportModel(
      id: existing.id,
      animalId: existing.animalId,
      animalName: existing.animalName,
      tagNumber: existing.tagNumber,
      farmerId: existing.farmerId,
      farmerName: existing.farmerName,
      source: existing.source,
      status: "REJECTED",
      causeCategory: existing.causeCategory,
      causeDescription: existing.causeDescription,
      diseaseName: existing.diseaseName,
      recentlyTreated: existing.recentlyTreated,
      treatmentNotes: existing.treatmentNotes,
      notes: existing.notes,
      deathDateTime: existing.deathDateTime,
      reportedAt: existing.reportedAt,
      vetReviewedById: "vet-uuid-001",
      vetReviewedByName: "Dr. Arvind Sharma",
      vetReviewedAt: DateTime.now().toIso8601String(),
      vetRejectionReason: dto.rejectionReason,
      vetClinicalNotes: dto.clinicalNotes,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  @override
  Future<List<MortalityAuditDto>> getMortalityAudits(String id) async {
    return auditsList;
  }
}

Widget _createTestApp(Widget child) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale: const Locale("en"))),
    ],
    child: MaterialApp(
      locale: const Locale("en"),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockVetMortalityRepository mockRepo;

  setUp(() {
    mockRepo = MockVetMortalityRepository();
    mortalityNotifier.setRepository(mockRepo);
    mortalityNotifier.setSelectedCase(null);
    mortalityNotifier.clearMessages();
  });

  group("Phase 2 DTO & Model Serialization", () {
    test("ConfirmMortalityDto json serialization and deserialization", () {
      const dto = ConfirmMortalityDto(
        causeCategory: "KNOWN_DISEASE",
        diseaseName: "Anthrax",
        clinicalNotes: "Splenomegaly observed upon post-mortem",
        postMortemConducted: true,
      );

      final jsonMap = dto.toJson();
      expect(jsonMap["causeCategory"], "KNOWN_DISEASE");
      expect(jsonMap["diseaseName"], "Anthrax");
      expect(jsonMap["clinicalNotes"], "Splenomegaly observed upon post-mortem");
      expect(jsonMap["postMortemConducted"], true);

      final fromJson = ConfirmMortalityDto.fromJson(jsonMap);
      expect(fromJson.causeCategory, dto.causeCategory);
      expect(fromJson.diseaseName, dto.diseaseName);
      expect(fromJson.clinicalNotes, dto.clinicalNotes);
      expect(fromJson.postMortemConducted, dto.postMortemConducted);
    });

    test("RejectMortalityDto json serialization and deserialization", () {
      const dto = RejectMortalityDto(
        rejectionReason: "Animal verified alive and grazing on pasture",
        clinicalNotes: "Inspected at barn on 2026-09-05",
      );

      final jsonMap = dto.toJson();
      expect(jsonMap["rejectionReason"], "Animal verified alive and grazing on pasture");
      expect(jsonMap["clinicalNotes"], "Inspected at barn on 2026-09-05");

      final fromJson = RejectMortalityDto.fromJson(jsonMap);
      expect(fromJson.rejectionReason, dto.rejectionReason);
      expect(fromJson.clinicalNotes, dto.clinicalNotes);
    });

    test("MortalityAuditDto deserialization", () {
      final jsonMap = {
        "id": "audit-uuid-101",
        "mortalityEventId": "mortality-uuid-555",
        "veterinarianId": "vet-uuid-001",
        "veterinarianName": "Dr. Arvind Sharma",
        "action": "VET_CONFIRMATION",
        "oldStatus": "REPORTED",
        "newStatus": "VET_CONFIRMED",
        "clinicalNotes": "Confirmed anthrax hemorrhagic discharge",
        "confirmedCauseCategory": "KNOWN_DISEASE",
        "confirmedDiseaseName": "Anthrax",
        "createdAt": "2026-09-05T10:00:00Z",
      };

      final audit = MortalityAuditDto.fromJson(jsonMap);
      expect(audit.id, "audit-uuid-101");
      expect(audit.action, "VET_CONFIRMATION");
      expect(audit.veterinarianName, "Dr. Arvind Sharma");
      expect(audit.newStatus, "VET_CONFIRMED");
      expect(audit.confirmedDiseaseName, "Anthrax");
    });
  });

  group("Phase 2 MortalityNotifier Review Logic", () {
    test("loadPendingCases fetches cases into provider state", () async {
      mockRepo.pendingList = [
        MortalityReportModel(
          id: "case-1",
          animalId: "animal-1",
          tagNumber: "TAG-9001",
          animalName: "Lakshmi",
          farmerName: "Kishore Kumar",
          source: "FARMER_REPORTED",
          status: "REPORTED",
          causeCategory: "SUSPECTED_DISEASE",
          diseaseName: "Foot and Mouth Disease (FMD)",
          reportedAt: "2026-09-05T08:00:00Z",
          createdAt: "2026-09-05T08:00:00Z",
          updatedAt: "2026-09-05T08:00:00Z",
        ),
      ];

      await mortalityNotifier.loadPendingCases();
      expect(mortalityNotifier.pendingCases.length, 1);
      expect(mortalityNotifier.pendingCases.first.tagNumber, "TAG-9001");
    });

    test("confirmCase calls repository and removes case from pending", () async {
      mockRepo.pendingList = [
        MortalityReportModel(
          id: "case-1",
          animalId: "animal-1",
          tagNumber: "TAG-9001",
          animalName: "Lakshmi",
          farmerName: "Kishore Kumar",
          source: "FARMER_REPORTED",
          status: "REPORTED",
          causeCategory: "SUSPECTED_DISEASE",
          diseaseName: "Foot and Mouth Disease (FMD)",
          reportedAt: "2026-09-05T08:00:00Z",
          createdAt: "2026-09-05T08:00:00Z",
          updatedAt: "2026-09-05T08:00:00Z",
        ),
      ];

      await mortalityNotifier.loadPendingCases();
      expect(mortalityNotifier.pendingCases.length, 1);

      final ok = await mortalityNotifier.confirmCase(
        "case-1",
        const ConfirmMortalityDto(
          causeCategory: "KNOWN_DISEASE",
          diseaseName: "Foot and Mouth Disease (FMD)",
          clinicalNotes: "Oral vesicles confirmed",
          postMortemConducted: true,
        ),
      );

      expect(ok, true);
      expect(mockRepo.lastConfirmedId, "case-1");
      expect(mockRepo.lastConfirmDto?.postMortemConducted, true);
      expect(mortalityNotifier.pendingCases, isEmpty);
      expect(mortalityNotifier.selectedCase?.status, "VET_CONFIRMED");
    });

    test("rejectCase calls repository and marks as rejected", () async {
      mockRepo.pendingList = [
        MortalityReportModel(
          id: "case-2",
          animalId: "animal-2",
          tagNumber: "TAG-9002",
          animalName: "Ganga",
          farmerName: "Rakesh",
          source: "FARMER_REPORTED",
          status: "REPORTED",
          causeCategory: "UNKNOWN",
          reportedAt: "2026-09-05T08:00:00Z",
          createdAt: "2026-09-05T08:00:00Z",
          updatedAt: "2026-09-05T08:00:00Z",
        ),
      ];

      await mortalityNotifier.loadPendingCases();

      final ok = await mortalityNotifier.rejectCase(
        "case-2",
        const RejectMortalityDto(
          rejectionReason: "Duplicate entry filed by caretaker",
          clinicalNotes: "Verified via phone interview with owner",
        ),
      );

      expect(ok, true);
      expect(mockRepo.lastRejectedId, "case-2");
      expect(mockRepo.lastRejectDto?.rejectionReason, "Duplicate entry filed by caretaker");
      expect(mortalityNotifier.pendingCases, isEmpty);
      expect(mortalityNotifier.selectedCase?.status, "REJECTED");
    });
  });

  group("Phase 2 UI Widgets", () {
    testWidgets("VetMortalityListPage displays pending case cards", (tester) async {
      mockRepo.pendingList = [
        MortalityReportModel(
          id: "case-1",
          animalId: "animal-1",
          tagNumber: "TAG-9001",
          animalName: "Lakshmi",
          farmerName: "Kishore Kumar",
          source: "FARMER_REPORTED",
          status: "REPORTED",
          causeCategory: "SUSPECTED_DISEASE",
          diseaseName: "Foot and Mouth Disease (FMD)",
          reportedAt: "2026-09-05T08:00:00Z",
          createdAt: "2026-09-05T08:00:00Z",
          updatedAt: "2026-09-05T08:00:00Z",
        ),
      ];

      await tester.pumpWidget(_createTestApp(const VetMortalityListPage()));
      await tester.pumpAndSettle();

      expect(find.text("Mortality Case Reviews"), findsOneWidget);
      expect(find.text("TAG-9001"), findsOneWidget);
      expect(find.text("Lakshmi"), findsOneWidget);
      expect(find.text("Farmer: Kishore Kumar"), findsOneWidget);
      expect(find.text("Review Case"), findsOneWidget);
    });

    testWidgets("VetMortalityDetailPage renders case breakdown and action buttons", (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      final sampleReport = MortalityReportModel(
        id: "case-100",
        animalId: "animal-100",
        tagNumber: "TAG-4400",
        animalName: "Kamdhenu",
        farmerName: "Anand Verma",
        source: "FARMER_REPORTED",
        status: "REPORTED",
        causeCategory: "KNOWN_DISEASE",
        diseaseName: "Anthrax",
        recentlyTreated: true,
        treatmentNotes: "Administered penicillin on 2026-09-03",
        notes: "Sudden collapse with bleeding",
        latitude: 28.6139,
        longitude: 77.2090,
        locationAccuracy: 12.0,
        reportedAt: "2026-09-05T09:00:00Z",
        createdAt: "2026-09-05T09:00:00Z",
        updatedAt: "2026-09-05T09:00:00Z",
      );

      mockRepo.auditsList = [
        const MortalityAuditDto(
          id: "audit-1",
          mortalityEventId: "case-100",
          veterinarianId: "vet-1",
          veterinarianName: "Dr. Sharma",
          action: "REFERRAL_DISPATCHED",
          oldStatus: "REPORTED",
          newStatus: "REPORTED",
          createdAt: "2026-09-05T09:05:00Z",
        ),
      ];

      await tester.pumpWidget(_createTestApp(VetMortalityDetailPage(report: sampleReport)));
      await tester.pumpAndSettle();

      expect(find.text("Mortality Validation"), findsOneWidget);
      expect(find.text("Pending Epidemiological Validation"), findsOneWidget);
      expect(find.text("TAG-4400"), findsOneWidget);
      expect(find.text("Kamdhenu"), findsOneWidget);
      expect(find.text("Anand Verma"), findsOneWidget);
      expect(find.text("Validate & Confirm Mortality"), findsOneWidget);
      expect(find.text("Reject Case Report"), findsOneWidget);
    });
  });
}
