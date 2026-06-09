import 'package:flutter_test/flutter_test.dart';
import 'package:translator_app/viewmodels/translation_viewmodel.dart';
import 'package:translator_app/models/language.dart';

void main() {
  late TranslationViewModel viewModel;

  setUp(() {
    viewModel = TranslationViewModel();
  });

  group('TranslationViewModel', () {
    test('initial state is empty', () {
      expect(viewModel.sourceText, isEmpty);
      expect(viewModel.translatedText, isEmpty);
      expect(viewModel.isTranslating, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.sourceLanguage, isNull);
      expect(viewModel.targetLanguage, isNull);
    });

    test('setSourceText updates source text', () {
      viewModel.setSourceText('Hello');
      expect(viewModel.sourceText, equals('Hello'));
    });

    test('setSourceLanguage updates source language', () {
      final lang = Language(code: 'es', name: 'Spanish', nativeName: 'Español');
      viewModel.setSourceLanguage(lang);
      expect(viewModel.sourceLanguage?.code, equals('es'));
    });

    test('setTargetLanguage updates target language', () {
      final lang = Language(code: 'fr', name: 'French', nativeName: 'Français');
      viewModel.setTargetLanguage(lang);
      expect(viewModel.targetLanguage?.code, equals('fr'));
    });

    test('swapLanguages swaps source and target', () {
      final spanish = Language(
        code: 'es',
        name: 'Spanish',
        nativeName: 'Español',
      );
      final french = Language(
        code: 'fr',
        name: 'French',
        nativeName: 'Français',
      );
      viewModel.setSourceLanguage(spanish);
      viewModel.setTargetLanguage(french);
      viewModel.setSourceText('Hola');

      viewModel.swapLanguages();

      expect(viewModel.sourceLanguage?.code, equals('fr'));
      expect(viewModel.targetLanguage?.code, equals('es'));
    });

    test('translate with empty text shows error', () async {
      await viewModel.translate();
      expect(viewModel.errorMessage, isNotNull);
    });

    test('translate with no languages selected shows error', () async {
      viewModel.setSourceText('Hello');
      await viewModel.translate();
      expect(viewModel.errorMessage, isNotNull);
    });

    test('clear resets all state', () {
      viewModel.setSourceText('Hello');
      viewModel.clear();
      expect(viewModel.sourceText, isEmpty);
      expect(viewModel.translatedText, isEmpty);
      expect(viewModel.errorMessage, isNull);
    });

    test('sourceLanguages and targetLanguages are populated', () {
      expect(viewModel.sourceLanguages, isNotEmpty);
      expect(viewModel.targetLanguages, isNotEmpty);
    });
  });
}
