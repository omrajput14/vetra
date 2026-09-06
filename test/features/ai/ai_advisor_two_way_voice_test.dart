import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/features/ai/data/models/ai_advisor_models.dart';
import 'package:vetra/features/ai/presentation/pages/ai_advisor_page.dart';
import 'package:vetra/features/ai/presentation/providers/ai_advisor_provider.dart';
import 'package:vetra/l10n/app_localizations.dart';

Widget _createTestAppWithLocale(Widget child, {Locale locale = const Locale('en')}) {
  return ProviderScope(
    overrides: [
      localeProvider.overrideWith((ref) => LocaleNotifier(initialLocale: locale)),
    ],
    child: MaterialApp(
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AI Advisor Two-Way Voice & Multilingual TTS Tests', () {
    testWidgets('Renders Read Aloud action on AI Advisor response cards in English',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'voice-session-en',
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
            id: 'user-msg-1',
            senderType: 'USER',
            content: 'My cow has a fever and is not eating.',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'ai-msg-1',
            senderType: 'ADVISOR',
            content: 'I observe signs of possible pyrexia. Is she drinking water normally?',
            turnNumber: 1,
            followUpQuestions: const ['Yes', 'No'],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestAppWithLocale(
        const AIAdvisorPage(animalId: 'animal-1'),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      // Verify AI message and Read Aloud action exist
      expect(find.text('I observe signs of possible pyrexia. Is she drinking water normally?'), findsOneWidget);
      expect(find.text('Read Aloud'), findsOneWidget);
      expect(find.byIcon(Icons.volume_up_outlined), findsOneWidget);
    });

    testWidgets('Renders Read Aloud action in Marathi (ऐका)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'voice-session-mr',
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
            id: 'user-msg-mr',
            senderType: 'USER',
            content: 'माझ्या गायीला ताप आहे.',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'ai-msg-mr',
            senderType: 'ADVISOR',
            content: 'गायीला ताप असल्याने ती पाणी व्यवस्थित पीत आहे का?',
            turnNumber: 1,
            followUpQuestions: const ['होय', 'नाही'],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestAppWithLocale(
        const AIAdvisorPage(animalId: 'animal-1'),
        locale: const Locale('mr'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('गायीला ताप असल्याने ती पाणी व्यवस्थित पीत आहे का?'), findsOneWidget);
      expect(find.text('ऐका'), findsOneWidget);
    });

    testWidgets('Renders Read Aloud action in Hindi (सुनें)',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'voice-session-hi',
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
            id: 'user-msg-hi',
            senderType: 'USER',
            content: 'मेरी गाय को बुखार है।',
            turnNumber: 1,
            followUpQuestions: const [],
            createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
          ),
          AIAdvisorMessageModel(
            id: 'ai-msg-hi',
            senderType: 'ADVISOR',
            content: 'गाय को बुखार होने पर क्या वह पानी पी रही है?',
            turnNumber: 1,
            followUpQuestions: const ['हाँ', 'नहीं'],
            createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
          ),
        ],
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        updatedAt: DateTime.now(),
      );

      aiAdvisorNotifier.setCurrentSession(session);

      await tester.pumpWidget(_createTestAppWithLocale(
        const AIAdvisorPage(animalId: 'animal-1'),
        locale: const Locale('hi'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('गाय को बुखार होने पर क्या वह पानी पी रही है?'), findsOneWidget);
      expect(find.text('सुनें'), findsOneWidget);
    });

    testWidgets('Tapping microphone button triggers voice toggle without crashing',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final session = AIAdvisorSessionModel(
        id: 'voice-session-mic',
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

      await tester.pumpWidget(_createTestAppWithLocale(
        const AIAdvisorPage(animalId: 'animal-1'),
        locale: const Locale('en'),
      ));
      await tester.pumpAndSettle();

      final micButton = find.byIcon(Icons.mic_none_rounded);
      expect(micButton, findsOneWidget);

      // Tap microphone
      await tester.tap(micButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // App remains alive and stable
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
