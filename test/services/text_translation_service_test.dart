import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/services/text_translation_service.dart';

void main() {
  late TextTranslationService service;

  setUp(() {
    service = TextTranslationService();
  });

  group('TextTranslationService', () {
    test(
      'isOfflineAvailable returns true for languages with offline models',
      () {
        expect(service.isOfflineAvailable('en'), isTrue);
        expect(service.isOfflineAvailable('es'), isTrue);
        expect(service.isOfflineAvailable('fr'), isTrue);
      },
    );

    test(
      'isOfflineAvailable returns false for languages without offline models',
      () {
        expect(service.isOfflineAvailable('ja'), isFalse);
        expect(service.isOfflineAvailable('ko'), isFalse);
      },
    );

    test('translateOnline throws when API key is not configured', () async {
      expect(
        () => service.translateOnline('Hello', 'en', 'es'),
        throwsA(isA<Exception>()),
      );
    });

    test('translateOffline throws for unsupported language', () async {
      expect(
        () => service.translateOffline('Hello', 'ja', 'en'),
        throwsA(isA<UnsupportedError>()),
      );
    });
  });
}
