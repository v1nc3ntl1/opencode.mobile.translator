import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/app.dart';

void main() {
  testWidgets('app renders translate screen', (WidgetTester tester) async {
    await tester.pumpWidget(const TranslatorApp());

    expect(find.text('Translate'), findsAtLeastNWidgets(1));
  });
}
