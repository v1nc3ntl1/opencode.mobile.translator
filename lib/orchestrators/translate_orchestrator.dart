import 'dart:math';
import '../models/translation_record.dart';
import '../services/text_translation_service.dart';
import '../core/cache_manager.dart';
import '../core/connectivity_monitor.dart';
import '../core/database_helper.dart';

class TranslateOrchestrator {
  final TextTranslationService _translationService;
  final CacheManager _cacheManager;
  final ConnectivityMonitor _connectivityMonitor;
  final DatabaseHelper _dbHelper;

  TranslateOrchestrator({
    required TextTranslationService translationService,
    required CacheManager cacheManager,
    required ConnectivityMonitor connectivityMonitor,
    required DatabaseHelper dbHelper,
  }) : _translationService = translationService,
       _cacheManager = cacheManager,
       _connectivityMonitor = connectivityMonitor,
       _dbHelper = dbHelper;

  Future<TranslationResult> translate({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    if (text.trim().isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }
    if (sourceLanguage == targetLanguage) {
      throw ArgumentError('Source and target languages must differ');
    }

    // 1. Check cache
    final cached = _cacheManager.get(text, sourceLanguage, targetLanguage);
    if (cached != null) {
      return TranslationResult(
        translatedText: cached,
        source: TranslationSource.cache,
        confidence: 1.0,
      );
    }

    String translatedText;
    TranslationSource source;
    double confidence;

    // 2. Try offline or online
    if (_connectivityMonitor.isOnline) {
      try {
        translatedText = await _translationService.translateOnline(
          text,
          sourceLanguage,
          targetLanguage,
        );
        source = TranslationSource.cloud;
        confidence = 0.98;
      } catch (e) {
        // Fallback to offline if online fails
        try {
          translatedText = await _translationService.translateOffline(
            text,
            sourceLanguage,
            targetLanguage,
          );
          source = TranslationSource.offline;
          confidence = 0.90;
        } catch (offlineError) {
          throw TranslationException(
            'Translation failed: $e',
            originalError: e is Exception ? e : Exception(e.toString()),
          );
        }
      }
    } else {
      // Offline mode
      try {
        translatedText = await _translationService.translateOffline(
          text,
          sourceLanguage,
          targetLanguage,
        );
        source = TranslationSource.offline;
        confidence = 0.90;
      } catch (e) {
        throw TranslationException(
          'No internet connection and offline translation is unavailable.',
          originalError: e is Exception ? e : Exception(e.toString()),
        );
      }
    }

    // 3. Cache result
    _cacheManager.set(text, sourceLanguage, targetLanguage, translatedText);

    // 4. Save to history
    final record = TranslationRecord(
      id: _generateId(),
      sourceText: text,
      translatedText: translatedText,
      sourceLanguage: sourceLanguage,
      targetLanguage: targetLanguage,
      sourceType: 'manual',
      confidenceScore: confidence,
    );
    await _dbHelper.insertTranslationRecord(record);

    return TranslationResult(
      translatedText: translatedText,
      source: source,
      confidence: confidence,
      record: record,
    );
  }

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(99999);
    return 'tr_${timestamp}_$random';
  }
}

enum TranslationSource { cache, offline, cloud }

class TranslationResult {
  final String translatedText;
  final TranslationSource source;
  final double confidence;
  final TranslationRecord? record;

  TranslationResult({
    required this.translatedText,
    required this.source,
    required this.confidence,
    this.record,
  });
}

class TranslationException implements Exception {
  final String message;
  final Exception? originalError;

  TranslationException(this.message, {this.originalError});

  @override
  String toString() => 'TranslationException: $message';
}
