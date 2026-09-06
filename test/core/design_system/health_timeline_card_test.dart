import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/design_system/cards/health_timeline_card.dart';
import 'package:vetra/features/animal/data/models/animal_health_record_dto.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('HealthTimelineCard renders AI_SCREENING record correctly', (tester) async {
    final record = AnimalHealthRecordModel(
      id: 'rec-1',
      animalId: 'anim-1',
      recordType: 'AI_SCREENING',
      source: 'AI_ADVISOR',
      title: 'Possible Digestive Disturbance',
      description: 'AI observed reduced rumination indicator',
      symptoms: 'Loss of appetite',
      diagnosis: 'Indigestion Risk',
      recordedAt: '2026-08-22T10:30:00Z',
    );

    await tester.pumpWidget(createTestWidget(HealthTimelineCard(record: record)));
    await tester.pumpAndSettle();

    expect(find.text('Possible Digestive Disturbance'), findsOneWidget);
    expect(find.text('AI observed reduced rumination indicator'), findsOneWidget);
    expect(find.text('Loss of appetite'), findsOneWidget);
    expect(find.text('Indigestion Risk'), findsOneWidget);
    expect(find.text('AI_ADVISOR'), findsOneWidget);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
  });

  testWidgets('HealthTimelineCard renders VACCINATION record correctly', (tester) async {
    final record = AnimalHealthRecordModel(
      id: 'rec-2',
      animalId: 'anim-1',
      recordType: 'VACCINATION',
      source: 'VETERINARIAN',
      title: 'Foot and Mouth Disease (FMD) Booster',
      treatment: 'FMD Vaccine 5ml SQ',
      veterinarianName: 'Dr. Ananya Roy',
      recordedAt: '2026-08-10T09:00:00Z',
    );

    await tester.pumpWidget(createTestWidget(HealthTimelineCard(record: record)));
    await tester.pumpAndSettle();

    expect(find.text('Foot and Mouth Disease (FMD) Booster'), findsOneWidget);
    expect(find.text('FMD Vaccine 5ml SQ'), findsOneWidget);
    expect(find.text('Dr. Ananya Roy'), findsOneWidget);
    expect(find.text('VETERINARIAN'), findsOneWidget);
    expect(find.byIcon(Icons.vaccines_outlined), findsOneWidget);
  });
}
