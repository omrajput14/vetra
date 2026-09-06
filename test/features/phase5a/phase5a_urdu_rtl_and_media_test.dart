import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vetra/core/design_system/cards/animal_card.dart';
import 'package:vetra/core/localization/locale_provider.dart';
import 'package:vetra/core/widgets/authenticated_image.dart';
import 'package:vetra/core/widgets/image_picker_field.dart';
import 'package:vetra/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PHASE 5A: Urdu Localization & RTL Support Tests', () {
    test('LocaleProvider correctly identifies Urdu native and display names', () {
      expect(AppLocales.getLanguageName('ur'), equals('اردو (Urdu)'));
      expect(AppLocales.getLanguageNativeName('ur'), equals('اردو'));
      expect(AppLocales.supported.contains(const Locale('ur')), isTrue);
    });

    test('LocaleNotifier switches locale to Urdu and persists preference', () async {
      final notifier = LocaleNotifier();
      await notifier.setLanguageCode('ur');
      expect(notifier.state, equals(const Locale('ur')));
      expect(notifier.state.languageCode, equals('ur'));

      await notifier.setLanguageCode('en');
      expect(notifier.state, equals(const Locale('en')));
    });

    testWidgets('AppLocalizations loads Urdu strings and preserves technical terms', (tester) async {
      late AppLocalizations localizations;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              localizations = AppLocalizations.of(context)!;
              return Scaffold(
                body: Center(
                  child: Column(
                    children: [
                      Text(localizations.appName),
                      Text(localizations.myAnimals),
                      Text(localizations.scanAnimalQr),
                      Text(localizations.animalPhoto),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check appName contains preserved term PASHU SATHI
      expect(localizations.appName, contains('PASHU SATHI'));
      expect(localizations.myAnimals, contains('میرے جانور'));
      expect(localizations.scanAnimalQr, contains('QR'));
      expect(localizations.takePhotoCamera, contains('کیمرہ'));
      expect(localizations.chooseFromGallery, contains('گیلری'));
    });

    testWidgets('Urdu locale renders with RTL TextDirection', (tester) async {
      TextDirection? direction;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              direction = Directionality.of(context);
              return Scaffold(
                body: Center(
                  child: Text(AppLocalizations.of(context)!.appName),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(direction, equals(TextDirection.rtl));
    });

    testWidgets('English locale renders with LTR TextDirection', (tester) async {
      TextDirection? direction;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              direction = Directionality.of(context);
              return Scaffold(
                body: Center(
                  child: Text(AppLocalizations.of(context)!.appName),
                ),
              );
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(direction, equals(TextDirection.ltr));
    });
  });

  group('PHASE 5A: Animal & Farmer Media Picker UI Tests', () {
    testWidgets('ImagePickerField renders camera and gallery action buttons when empty', (tester) async {
      String? changedPath;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImagePickerField(
                label: 'Animal Photo',
                onImageChanged: (path) {
                  changedPath = path;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Animal Photo'), findsOneWidget);
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.byIcon(Icons.camera_alt_outlined), findsOneWidget);
      expect(changedPath, isNull);
      expect(find.byIcon(Icons.photo_library_outlined), findsOneWidget);
    });

    testWidgets('ImagePickerField renders in Urdu with localized button labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ur'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ImagePickerField(
                label: 'جانور کی تصویر',
                onImageChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('جانور کی تصویر'), findsOneWidget);
      expect(find.text('کیمرہ'), findsOneWidget);
      expect(find.text('گیلری'), findsOneWidget);
    });

    testWidgets('AuthenticatedImage renders placeholder when no photo provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AuthenticatedImage(
                localPhotoPath: null,
                photoUrl: null,
                width: 64,
                height: 64,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pets), findsOneWidget);
    });

    testWidgets('AnimalCard renders with AuthenticatedImage thumbnail', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimalCard(
              name: 'Gauri (Cow)',
              tagId: 'MH-10293',
              breed: 'Gir Cow',
              status: 'HEALTHY',
              photoUrl: '/api/v1/animals/anim-001/photo',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gauri (Cow)'), findsOneWidget);
      expect(find.text('Tag #MH-10293 • Gir Cow'), findsOneWidget);
      expect(find.text('HEALTHY'), findsOneWidget);
      expect(find.byType(AuthenticatedImage), findsOneWidget);

      await tester.tap(find.byType(AnimalCard));
      expect(tapped, isTrue);
    });
  });
}
