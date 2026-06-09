import 'package:flutter/material.dart';
import '../models/language.dart';

class LanguagePicker extends StatelessWidget {
  final String? label;
  final Language? selectedLanguage;
  final List<Language> languages;
  final ValueChanged<Language> onChanged;
  final bool showFlag;

  const LanguagePicker({
    super.key,
    this.label,
    required this.selectedLanguage,
    required this.languages,
    required this.onChanged,
    this.showFlag = true,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Language>(
      value: selectedLanguage,
      decoration: InputDecoration(
        labelText: label ?? 'Language',
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      isExpanded: true,
      items:
          languages.map((lang) {
            return DropdownMenuItem<Language>(
              value: lang,
              child: Text(
                '${showFlag ? _flagFor(lang.code) : ''} ${lang.name}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  String _flagFor(String code) {
    switch (code) {
      case 'en':
        return '\u{1F1EC}\u{1F1E7}';
      case 'es':
        return '\u{1F1EA}\u{1F1F8}';
      case 'fr':
        return '\u{1F1EB}\u{1F1F7}';
      case 'de':
        return '\u{1F1E9}\u{1F1EA}';
      case 'it':
        return '\u{1F1EE}\u{1F1F9}';
      case 'pt':
        return '\u{1F1E7}\u{1F1F7}';
      case 'ru':
        return '\u{1F1F7}\u{1F1FA}';
      case 'ja':
        return '\u{1F1EF}\u{1F1F5}';
      case 'ko':
        return '\u{1F1F0}\u{1F1F7}';
      case 'zh':
        return '\u{1F1E8}\u{1F1F3}';
      case 'ar':
        return '\u{1F1E6}\u{1F1F7}';
      case 'nl':
        return '\u{1F1F3}\u{1F1F1}';
      default:
        return '\u{1F310}';
    }
  }
}
