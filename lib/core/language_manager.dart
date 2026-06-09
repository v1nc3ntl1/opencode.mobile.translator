import '../models/language.dart';

class LanguageManager {
  static final LanguageManager _instance = LanguageManager._internal();
  factory LanguageManager() => _instance;
  LanguageManager._internal();

  static const _defaultLanguages = [
    Language(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      isAsrSupported: true,
      isTtsSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      isAsrSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'fr',
      name: 'French',
      nativeName: 'Français',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      isAsrSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'de',
      name: 'German',
      nativeName: 'Deutsch',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'it',
      name: 'Italian',
      nativeName: 'Italiano',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'pt',
      name: 'Portuguese',
      nativeName: 'Português',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
      offlineModelAvailable: true,
    ),
    Language(
      code: 'ru',
      name: 'Russian',
      nativeName: 'Русский',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
    Language(
      code: 'ja',
      name: 'Japanese',
      nativeName: '日本語',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
    Language(
      code: 'ko',
      name: 'Korean',
      nativeName: '한국어',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
    Language(
      code: 'zh',
      name: 'Chinese (Simplified)',
      nativeName: '简体中文',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
    Language(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
    Language(
      code: 'nl',
      name: 'Dutch',
      nativeName: 'Nederlands',
      isSourceSupported: true,
      isTargetSupported: true,
      isOcrSupported: true,
    ),
  ];

  List<Language> get supportedLanguages => List.unmodifiable(_defaultLanguages);

  List<Language> get sourceLanguages =>
      _defaultLanguages.where((l) => l.isSourceSupported).toList();

  List<Language> get targetLanguages =>
      _defaultLanguages.where((l) => l.isTargetSupported).toList();

  List<Language> get offlineLanguages =>
      _defaultLanguages.where((l) => l.offlineModelAvailable).toList();

  Language? getLanguage(String code) {
    try {
      return _defaultLanguages.firstWhere((l) => l.code == code);
    } catch (_) {
      return null;
    }
  }

  bool isLanguageSupported(String code) =>
      _defaultLanguages.any((l) => l.code == code);
}
