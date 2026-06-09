import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/language_manager.dart';

class TextTranslationService {
  final LanguageManager _languageManager = LanguageManager();
  final String? _apiKey;

  TextTranslationService({String? apiKey}) : _apiKey = apiKey;

  Future<String> translateOnline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    if (_apiKey == null || _apiKey.isEmpty) {
      throw Exception(
        'Google Cloud Translation API key not configured. '
        'Pass it via --dart-define=GOOGLE_TRANSLATE_API_KEY=<key>',
      );
    }

    final url = Uri.parse(
      'https://translation.googleapis.com/language/translate/v2',
    );

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': text,
        'source': sourceLanguage,
        'target': targetLanguage,
        'format': 'text',
        'key': _apiKey,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final translations = data['data']['translations'] as List;
      return translations[0]['translatedText'] as String;
    } else {
      throw Exception(
        'Translation API error: ${response.statusCode} ${response.body}',
      );
    }
  }

  Future<String> translateOffline(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    final language = _languageManager.getLanguage(sourceLanguage);
    if (language == null || !language.offlineModelAvailable) {
      throw UnsupportedError(
        'Offline translation not available for $sourceLanguage',
      );
    }

    // ML Kit on-device translation — will throw if model not downloaded
    try {
      final translatedText = await _translateWithMlKit(
        text,
        sourceLanguage,
        targetLanguage,
      );
      return translatedText;
    } catch (e) {
      throw Exception('Offline translation failed: $e');
    }
  }

  Future<String> _translateWithMlKit(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    // ML Kit translation bridge — delegates to platform-specific implementation
    // In a Flutter app, this would use google_mlkit_translation:
    //
    // final translator = GoogleTranslator(
    //   sourceLanguage: TranslateLanguage.fromValue(sourceLanguage),
    //   targetLanguage: TranslateLanguage.fromValue(targetLanguage),
    // );
    // try {
    //   await translator.translate(text);
    // } finally {
    //   translator.close();
    // }

    throw UnimplementedError(
      'ML Kit on-device translation requires platform setup. '
      'See https://pub.dev/packages/google_mlkit_translation',
    );
  }

  bool isOfflineAvailable(String languageCode) =>
      _languageManager.getLanguage(languageCode)?.offlineModelAvailable ??
      false;
}
