import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/core/cache_manager.dart';

void main() {
  group('CacheManager', () {
    test('caches and returns translations', () {
      final cache = CacheManager();
      cache.set('Hello', 'en', 'es', 'Hola');
      expect(cache.get('Hello', 'en', 'es'), equals('Hola'));
      expect(cache.get('HELLO', 'en', 'es'), equals('Hola'));
    });

    test('returns null for uncached text', () {
      final cache = CacheManager();
      expect(cache.get('Hello', 'en', 'es'), isNull);
      expect(cache.get('World', 'en', 'fr'), isNull);
    });

    test('respects max entries', () {
      final cache = CacheManager();
      for (var i = 0; i < cache.maxEntries + 10; i++) {
        cache.set('text$i', 'en', 'es', 'trans$i');
      }
      expect(cache.size, lessThanOrEqualTo(cache.maxEntries));
    });
  });
}
