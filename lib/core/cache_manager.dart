import 'dart:collection';

class CacheManager {
  static const int _maxEntries = 200;

  final LinkedHashMap<String, String> _cache = LinkedHashMap();

  String _buildKey(
    String sourceText,
    String sourceLanguage,
    String targetLanguage,
  ) => '$sourceLanguage:$targetLanguage:${sourceText.toLowerCase().trim()}';

  String? get(String sourceText, String sourceLanguage, String targetLanguage) {
    final key = _buildKey(sourceText, sourceLanguage, targetLanguage);
    final value = _cache[key];
    if (value != null) {
      _cache.remove(key);
      _cache[key] = value;
    }
    return value;
  }

  void set(
    String sourceText,
    String sourceLanguage,
    String targetLanguage,
    String translatedText,
  ) {
    final key = _buildKey(sourceText, sourceLanguage, targetLanguage);
    _cache[key] = translatedText;
    if (_cache.length > _maxEntries) {
      _cache.remove(_cache.keys.first);
    }
  }

  void remove(String sourceText, String sourceLanguage, String targetLanguage) {
    final key = _buildKey(sourceText, sourceLanguage, targetLanguage);
    _cache.remove(key);
  }

  void clear() => _cache.clear();

  int get size => _cache.length;
  int get maxEntries => _maxEntries;
}
