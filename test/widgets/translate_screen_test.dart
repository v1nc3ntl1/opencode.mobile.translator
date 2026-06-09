import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:translator_app/screens/translate_screen.dart';
import 'package:translator_app/viewmodels/translation_viewmodel.dart';

Widget createTestWidget() {
  return MaterialApp(
    home: ChangeNotifierProvider(
      create: (_) => TranslationViewModel(),
      child: const TranslateScreen(),
    ),
  );
}

void main() {
  group('TranslateScreen', () {
    testWidgets('renders title and key elements', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Translate'), findsAtLeastNWidgets(1));
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Enter text to translate...'), findsOneWidget);
      expect(find.text('Translation will appear here'), findsOneWidget);
    });

    testWidgets('shows swap languages button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      expect(find.byIcon(Icons.swap_horiz), findsOneWidget);
    });

    testWidgets('text input accepts user input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Hello world');
      await tester.pump();

      expect(find.text('Hello world'), findsOneWidget);
    });

    testWidgets('translate button is tappable with no error', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Hello');

      await tester.tap(find.byKey(const Key('translate_button')));
      await tester.pumpAndSettle();

      expect(find.textContaining('Please select'), findsOneWidget);
    });
  });
}
