import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/ai/data/models/ai_scan_model.dart';
import 'package:vetra/features/ai/presentation/pages/scan_results_page.dart';
import 'package:vetra/features/ai/presentation/providers/ai_scan_provider.dart';

void main() {
  group('ScanResultsPage UI Tests', () {
    testWidgets('renders preliminary AI assessment with structured fields',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockScan = AIScanModel(
        id: 'scan-123',
        animalId: 'animal-456',
        animalName: 'Gauri',
        imageUrl: 'https://s3.amazonaws.com/vetra/scans/test.jpg',
        aiProvider: 'GEMINI',
        aiModel: 'gemini-1.5-flash',
        diagnosis: 'Bovine Dermatophilosis (Suspected)',
        confidenceScore: 0.88,
        severity: 'MODERATE',
        observations: [
          'Localized crusty scabs with paintbrush appearance',
          'Mild superficial epidermal scaling',
        ],
        recommendedNextStep:
            'Isolate animal in dry shelter and schedule on-site veterinary evaluation.',
        requiresVeterinarianReview: true,
        disclaimer:
            'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
        status: 'COMPLETED',
      );

      aiScanNotifier.setLastScanResult(mockScan);

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanResultsPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen Title
      expect(find.text('Preliminary AI Assessment'), findsOneWidget);

      // Verify Condition Name
      expect(find.text('Bovine Dermatophilosis (Suspected)'), findsOneWidget);

      // Verify Severity Badge
      expect(find.text('MODERATE'), findsOneWidget);

      // Verify AI Confidence
      expect(find.text('AI Confidence'), findsOneWidget);
      expect(find.text('88.0%'), findsOneWidget);

      // Verify Observed Indicators
      expect(
          find.text('Localized crusty scabs with paintbrush appearance'),
          findsOneWidget);
      expect(find.text('Mild superficial epidermal scaling'), findsOneWidget);

      // Verify Recommended Next Step
      expect(find.text('Recommended Next Step'), findsOneWidget);
      expect(
          find.text(
              'Isolate animal in dry shelter and schedule on-site veterinary evaluation.'),
          findsOneWidget);

      // Verify Clinical Disclaimer
      expect(
          find.text(
              'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.'),
          findsOneWidget);

      // Verify Consultation Button
      expect(find.text('Book Vet Consultation'), findsOneWidget);
      expect(find.text('Return to Dashboard'), findsOneWidget);
    });

    testWidgets('handles inconclusive and missing observation state gracefully',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final inconclusiveScan = AIScanModel(
        id: 'scan-inconclusive',
        animalId: 'animal-456',
        imageUrl: '',
        diagnosis: 'Inconclusive / Insufficient Visual Evidence',
        confidenceScore: 0.20,
        severity: 'UNKNOWN',
        observations: const [],
        recommendedNextStep:
            'Schedule a clinical evaluation with a licensed veterinarian for on-site diagnosis.',
        requiresVeterinarianReview: true,
        disclaimer:
            'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
        status: 'COMPLETED',
      );

      aiScanNotifier.setLastScanResult(inconclusiveScan);

      await tester.pumpWidget(
        const MaterialApp(
          home: ScanResultsPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Inconclusive / Insufficient Visual Evidence'),
          findsOneWidget);
      expect(find.text('UNKNOWN'), findsOneWidget);
      expect(find.text('20.0%'), findsOneWidget);
      expect(find.text('Book Vet Consultation'), findsOneWidget);
    });
  });
}
