import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vetra/main.dart';

void main() {
  testWidgets('VetraApp smoke test renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VetraApp()));
    expect(find.byType(VetraApp), findsOneWidget);
    // Advance timer for SplashPage navigation
    await tester.pump(const Duration(seconds: 3));
  });
}
