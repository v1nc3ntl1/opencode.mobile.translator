import 'package:flutter/foundation.dart';
import '../models/language.dart';
import '../orchestrators/translate_orchestrator.dart';
import '../services/text_translation_service.dart';
import '../core/cache_manager.dart';
import '../core/connectivity_monitor.dart';
import '../core/database_helper.dart';
import '../core/language_manager.dart';

class TranslationViewModel extends ChangeNotifier {
  final TranslateOrchestrator _orchestrator;
  final LanguageManager _languageManager;

  TranslationViewModel({
    TranslateOrchestrator? orchestrator,
    LanguageManager? languageManager,
  }) : _orchestrator =
           orchestrator ??
           TranslateOrchestrator(
             translationService: TextTranslationService(),
             cacheManager: CacheManager(),
             connectivityMonitor: ConnectivityMonitor(),
             dbHelper: DatabaseHelper(),
           ),
       _languageManager = languageManager ?? LanguageManager();

  String _sourceText = '';
  String _translatedText = '';
  Language? _sourceLanguage;
  Language? _targetLanguage;
  bool _isTranslating = false;
  String? _errorMessage;
  TranslationSource? _lastSource;

  String get sourceText => _sourceText;
  String get translatedText => _translatedText;
  Language? get sourceLanguage => _sourceLanguage;
  Language? get targetLanguage => _targetLanguage;
  bool get isTranslating => _isTranslating;
  String? get errorMessage => _errorMessage;
  TranslationSource? get lastSource => _lastSource;

  List<Language> get sourceLanguages => _languageManager.sourceLanguages;
  List<Language> get targetLanguages => _languageManager.targetLanguages;

  void setSourceText(String text) {
    _sourceText = text;
    _errorMessage = null;
    notifyListeners();
  }

  void setSourceLanguage(Language language) {
    _sourceLanguage = language;
    _errorMessage = null;
    notifyListeners();
  }

  void setTargetLanguage(Language language) {
    _targetLanguage = language;
    _errorMessage = null;
    notifyListeners();
  }

  void swapLanguages() {
    final temp = _sourceLanguage;
    _sourceLanguage = _targetLanguage;
    _targetLanguage = temp;
    _sourceText = _translatedText;
    _translatedText = '';
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> translate() async {
    if (_sourceText.trim().isEmpty) {
      _errorMessage = 'Please enter text to translate';
      notifyListeners();
      return;
    }
    if (_sourceLanguage == null || _targetLanguage == null) {
      _errorMessage = 'Please select source and target languages';
      notifyListeners();
      return;
    }
    if (_sourceLanguage!.code == _targetLanguage!.code) {
      _errorMessage = 'Source and target languages must be different';
      notifyListeners();
      return;
    }

    _isTranslating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _orchestrator.translate(
        text: _sourceText,
        sourceLanguage: _sourceLanguage!.code,
        targetLanguage: _targetLanguage!.code,
      );
      _translatedText = result.translatedText;
      _lastSource = result.source;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('TranslationException: ', '');
      _translatedText = '';
    } finally {
      _isTranslating = false;
      notifyListeners();
    }
  }

  void clear() {
    _sourceText = '';
    _translatedText = '';
    _errorMessage = null;
    _lastSource = null;
    notifyListeners();
  }
}
