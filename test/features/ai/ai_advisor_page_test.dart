import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/features/ai/data/models/ai_advisor_models.dart';
import 'package:vetra/features/ai/presentation/pages/ai_advisor_page.dart';
import 'package:vetra/features/ai/presentation/providers/ai_advisor_provider.dart';
import 'package:vetra/features/animal/presentation/providers/animal_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

Widget _createTestApp(Widget child) {
  return ProviderScope(
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  group('AIAdvisorPage UI Tests', () {
    testWidgets('renders conversational turns and follow-up question chips',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'session-101',
        animalId: 'animal-1',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.questioning,
        riskLevel: AIAdvisorRiskLevel.mild,
        requiresVetReview: true,
        turnCount: 1,
        messages: [
          AIAdvisorMessageModel(
            id: 'msg-1',
            senderType: 'USER',
            content: 'Gauri has stopped eating grain today and seems slightly sluggish.',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'msg-2',
            senderType: 'ADVISOR',
            content: 'I understand Gauri has reduced appetite. To evaluate this properly, could you check her temperature and water intake?',
            turnNumber: 1,
            followUpQuestions: [
              'Is she drinking water normally?',
              'Have you observed any bloat or diarrhea?',
              'What is her body temperature?',
            ],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: 'animal-1')));
      await tester.pumpAndSettle();

      // Header verification
      expect(find.text('AI Veterinary Advisor'), findsOneWidget);
      expect(find.text('Assistive Clinical Screening'), findsOneWidget);

      // Message bubbles
      expect(
          find.text('Gauri has stopped eating grain today and seems slightly sluggish.'),
          findsOneWidget);
      expect(
          find.text(
              'I understand Gauri has reduced appetite. To evaluate this properly, could you check her temperature and water intake?'),
          findsOneWidget);

      // Follow-up question chips
      expect(find.text('Is she drinking water normally?'), findsOneWidget);
      expect(find.text('Have you observed any bloat or diarrhea?'), findsOneWidget);
      expect(find.text('What is her body temperature?'), findsOneWidget);
    });

    testWidgets('renders structured preliminary assessment with confidence and disclaimer',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      const assessment = AIAdvisorAssessmentModel(
        possibleConditions: [
          PossibleConditionModel(
            condition: 'Simple Indigestion / Rumen Stasis (Suspected)',
            confidence: 0.82,
            reasoning: 'Sudden feed change with acute inappetence and mild rumen sluggishness.',
          ),
        ],
        userReportedSymptoms: [
          'Reduced grain intake (reported by owner)',
          'Drinking water normally (confirmed by owner)',
        ],
        keyObservations: [
          'Acute feed refusal with preserved hydration',
          'Absence of high pyrexia or systemic respiratory distress',
        ],
        riskLevel: AIAdvisorRiskLevel.moderate,
        requiresVeterinarianReview: true,
        recommendedNextStep:
            'Provide fresh clean water and good quality dry roughage. Schedule veterinary examination if inappetence persists past 24 hours.',
        disclaimer:
            'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
      );

      final session = AIAdvisorSessionModel(
        id: 'session-102',
        animalId: 'animal-1',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.assessmentGenerated,
        riskLevel: AIAdvisorRiskLevel.moderate,
        requiresVetReview: true,
        turnCount: 2,
        assessment: assessment,
        messages: [
          AIAdvisorMessageModel(
            id: 'msg-3',
            senderType: 'ADVISOR',
            content: 'Based on the clinical indicators, here is the preliminary assessment:',
            turnNumber: 2,
            followUpQuestions: const [],
            assessment: assessment,
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: 'animal-1')));
      await tester.pumpAndSettle();

      // Assessment Header
      expect(find.text('Preliminary Assessment'), findsOneWidget);
      expect(find.text('Moderate'), findsOneWidget);

      // Suspected Condition & Confidence
      expect(
          find.text('Simple Indigestion / Rumen Stasis (Suspected)'),
          findsOneWidget);
      expect(find.text('AI Confidence 82%'), findsOneWidget);

      // Distinct sections: Owner-Reported Symptoms & AI Clinical Observations
      expect(find.text('Owner-Reported Symptoms & Vitals'), findsOneWidget);
      expect(find.text('Reduced grain intake (reported by owner)'), findsOneWidget);
      expect(find.text('Drinking water normally (confirmed by owner)'), findsOneWidget);

      expect(find.text('AI Clinical Observations'), findsOneWidget);
      expect(
          find.text('Acute feed refusal with preserved hydration'),
          findsOneWidget);

      // Recommended Supportive Care
      expect(find.text('Recommended Supportive Care'), findsOneWidget);
      expect(
          find.text(
              'Provide fresh clean water and good quality dry roughage. Schedule veterinary examination if inappetence persists past 24 hours.'),
          findsOneWidget);

      // Disclaimer
      expect(
          find.text(
              'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.'),
          findsOneWidget);

      // Consultation Button
      expect(find.text('Book Vet Consultation'), findsOneWidget);
    });

    testWidgets('renders urgent veterinary alert banner for critical risk status',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'session-emergency',
        animalId: 'animal-1',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.urgentVeterinaryReview,
        riskLevel: AIAdvisorRiskLevel.critical,
        requiresVetReview: true,
        turnCount: 1,
        messages: [
          AIAdvisorMessageModel(
            id: 'msg-emerg',
            senderType: 'ADVISOR',
            content: 'URGENT: Severe symptoms detected. Please contact a veterinary professional immediately.',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now(),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: 'animal-1')));
      await tester.pumpAndSettle();

      expect(find.text('Urgent Clinical Concern'), findsOneWidget);
      expect(
          find.text(
              'Reported symptoms warrant immediate on-site veterinary evaluation.'),
          findsOneWidget);
      expect(find.text('Book Vet'), findsOneWidget);
    });

    testWidgets('renders voice input microphone button and input bar',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'session-voice',
        animalId: 'animal-1',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.questioning,
        riskLevel: AIAdvisorRiskLevel.mild,
        requiresVetReview: true,
        turnCount: 1,
        messages: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: 'animal-1')));
      await tester.pumpAndSettle();

      // Find mic icon
      expect(find.byIcon(Icons.mic_none_rounded), findsOneWidget);
      // Find send icon
      expect(find.byIcon(Icons.send_rounded), findsOneWidget);
      // Find text field
      expect(find.byType(TextField), findsOneWidget);
    });
    testWidgets('renders No active animal context fallback when no animal is selected/registered',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      animalNotifier.setSelectedAnimalId(null);
      aiAdvisorNotifier.clearSession();
      aiAdvisorNotifier.setErrorMessage('No active animal context');

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: '')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('No active animal context'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('resolves active animal from animalNotifier when animalId is empty',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'session-resolved',
        animalId: 'animal-gauri',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.questioning,
        riskLevel: AIAdvisorRiskLevel.mild,
        requiresVetReview: true,
        turnCount: 1,
        messages: [
          AIAdvisorMessageModel(
            id: 'msg-1',
            senderType: 'USER',
            content: 'my cow is sick',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'msg-2',
            senderType: 'ADVISOR',
            content: 'How long has this condition been observed?',
            turnNumber: 1,
            followUpQuestions: const ['Is she eating normally?'],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);
      animalNotifier.setSelectedAnimalId('animal-gauri');

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: '')));
      await tester.pumpAndSettle();

      expect(find.text('my cow is sick'), findsOneWidget);
      expect(find.text('How long has this condition been observed?'), findsOneWidget);
      expect(find.text('Is she eating normally?'), findsOneWidget);
    });

    testWidgets('multi-turn progression advances when farmer replies for 1 day',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final multiTurnSession = AIAdvisorSessionModel(
        id: 'session-turn-progression',
        animalId: 'animal-gauri',
        animalName: 'Gauri',
        species: 'Cattle',
        breed: 'Gir',
        userId: 'user-1',
        status: AIAdvisorSessionStatus.assessmentGenerated,
        riskLevel: AIAdvisorRiskLevel.moderate,
        requiresVetReview: true,
        turnCount: 2,
        messages: [
          AIAdvisorMessageModel(
            id: 'm1',
            senderType: 'USER',
            content: 'my cow is sick',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
          ),
          AIAdvisorMessageModel(
            id: 'm2',
            senderType: 'ADVISOR',
            content: 'How long has this condition been observed?',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'm3',
            senderType: 'USER',
            content: 'for 1 day',
            turnNumber: 2,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
          AIAdvisorMessageModel(
            id: 'm4',
            senderType: 'ADVISOR',
            content: 'Thank you for confirming the 1-day timeline. Based on the symptoms and animal profile, here is the preliminary screening assessment.',
            turnNumber: 2,
            followUpQuestions: const [],
            createdAt: DateTime.now(),
          ),
        ],
        assessment: const AIAdvisorAssessmentModel(
          possibleConditions: [
            PossibleConditionModel(
              condition: 'Acute Ruminal Indigestion (Suspected)',
              confidence: 0.84,
              reasoning: 'Acute onset within 24 hours with appetite sluggishness.',
            ),
          ],
          userReportedSymptoms: ['Sick for 1 day', 'Appetite reduction'],
          keyObservations: ['Early onset digestive disturbance pattern'],
          riskLevel: AIAdvisorRiskLevel.moderate,
          requiresVeterinarianReview: true,
          recommendedNextStep: 'Keep animal in clean dry shelter and consult a veterinarian.',
          disclaimer: 'This is an AI-assisted preliminary assessment and is not a confirmed veterinary diagnosis.',
        ),
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(multiTurnSession);

      await tester.pumpWidget(_createTestApp(const AIAdvisorPage(animalId: 'animal-gauri')));
      await tester.pumpAndSettle();

      expect(find.text('my cow is sick'), findsOneWidget);
      expect(find.text('How long has this condition been observed?'), findsOneWidget);
      expect(find.text('for 1 day'), findsOneWidget);
      expect(
          find.text(
              'Thank you for confirming the 1-day timeline. Based on the symptoms and animal profile, here is the preliminary screening assessment.'),
          findsOneWidget);
      expect(find.text('Acute Ruminal Indigestion (Suspected)'), findsOneWidget);
    });
  });
}

