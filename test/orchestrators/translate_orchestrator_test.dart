import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/orchestrators/translate_orchestrator.dart';
import 'package:translator_app/services/text_translation_service.dart';
import 'package:translator_app/core/cache_manager.dart';
import 'package:translator_app/core/connectivity_monitor.dart';
import 'package:translator_app/core/database_helper.dart';

void main() {
  group('TranslateOrchestrator', () {
    test('throws on empty text', () async {
      final orchestrator = TranslateOrchestrator(
        translationService: TextTranslationService(),
        cacheManager: CacheManager(),
        connectivityMonitor: ConnectivityMonitor(),
        dbHelper: DatabaseHelper(),
      );

      expect(
        () => orchestrator.translate(
          text: '',
          sourceLanguage: 'en',
          targetLanguage: 'es',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when source and target are the same', () async {
      final orchestrator = TranslateOrchestrator(
        translationService: TextTranslationService(),
        cacheManager: CacheManager(),
        connectivityMonitor: ConnectivityMonitor(),
        dbHelper: DatabaseHelper(),
      );

      expect(
        () => orchestrator.translate(
          text: 'Hello',
          sourceLanguage: 'en',
          targetLanguage: 'en',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('throws when offline and no network', () async {
      final orchestrator = TranslateOrchestrator(
        translationService: TextTranslationService(),
        cacheManager: CacheManager(),
        connectivityMonitor: ConnectivityMonitor(),
        dbHelper: DatabaseHelper(),
      );

      final result = orchestrator.translate(
        text: 'Hello',
        sourceLanguage: 'en',
        targetLanguage: 'es',
      );
      expect(result, throwsA(isA<TranslationException>()));
    });
  });
}
