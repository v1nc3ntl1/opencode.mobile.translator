import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/translation_viewmodel.dart';
import '../widgets/language_picker.dart';
import '../widgets/translation_output.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TranslationViewModel(),
      child: const _TranslateScreenBody(),
    );
  }
}

class _TranslateScreenBody extends StatelessWidget {
  const _TranslateScreenBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        centerTitle: true,
        actions: [
          Consumer<TranslationViewModel>(
            builder:
                (_, vm, __) => IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  tooltip: 'Swap languages',
                  onPressed:
                      vm.sourceLanguage != null && vm.targetLanguage != null
                          ? vm.swapLanguages
                          : null,
                ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<TranslationViewModel>(
          builder:
              (_, vm, __) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Source language picker
                  LanguagePicker(
                    label: 'From',
                    selectedLanguage: vm.sourceLanguage,
                    languages: vm.sourceLanguages,
                    onChanged: vm.setSourceLanguage,
                  ),
                  const SizedBox(height: 12),

                  // Source text input
                  TextField(
                    controller: TextEditingController(text: vm.sourceText)
                      ..selection = TextSelection.fromPosition(
                        TextPosition(offset: vm.sourceText.length),
                      ),
                    maxLines: 4,
                    minLines: 2,
                    decoration: InputDecoration(
                      hintText: 'Enter text to translate...',
                      border: const OutlineInputBorder(),
                      alignLabelWithHint: true,
                      suffixIcon:
                          vm.sourceText.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: vm.clear,
                              )
                              : null,
                    ),
                    onChanged: vm.setSourceText,
                    textInputAction: TextInputAction.newline,
                  ),
                  const SizedBox(height: 16),

                  // Translate button
                  FilledButton.icon(
                    key: const Key('translate_button'),
                    onPressed: vm.isTranslating ? null : vm.translate,
                    icon:
                        vm.isTranslating
                            ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.translate),
                    label: Text(
                      vm.isTranslating ? 'Translating...' : 'Translate',
                    ),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Target language picker
                  LanguagePicker(
                    label: 'To',
                    selectedLanguage: vm.targetLanguage,
                    languages: vm.targetLanguages,
                    onChanged: vm.setTargetLanguage,
                  ),
                  const SizedBox(height: 20),

                  // Translation output
                  TranslationOutput(
                    translatedText: vm.translatedText,
                    isLoading: vm.isTranslating,
                    errorMessage: vm.errorMessage,
                    source: vm.lastSource,
                    onCopy:
                        vm.translatedText.isNotEmpty
                            ? () {
                              final text = vm.translatedText;
                              if (text.isNotEmpty) {
                                _copyToClipboard(context, text);
                              }
                            }
                            : null,
                    onClear: vm.translatedText.isNotEmpty ? vm.clear : null,
                  ),
                ],
              ),
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Clipboard.settext would go here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
