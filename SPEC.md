# SPEC.md — Translator Mobile App

## Product Goal

A mobile translation app that helps users understand foreign languages through
text translation, camera-based OCR capture with translation overlay, and
speech-to-text with English audio output — all working offline for the most
common language pairs.

## Target User

- **Travelers** reading foreign signs, menus, and documents
- **Language learners** practicing comprehension
- **Professionals** communicating across language barriers in meetings or chat

## Core Screens

| # | Screen | Purpose |
|---|---|---|
| 1 | **Text Translation** | Type/paste text -> select languages -> see translation |
| 2 | **OCR / Camera** | Point camera at text or import image -> see translated overlay |
| 3 | **Speech Input** | Tap mic -> speak -> see English text + hear English audio |
| 4 | **Audio Playback** | Play back translated audio with speed/pitch controls |
| 5 | **Settings** | Manage languages, voice preferences, offline model downloads |

## Minimum Entities

| Entity | Key Fields | Purpose |
|---|---|---|
| `Language` | code, name, supported feature flags, offline model flag | Supported language metadata |
| `TranslationRecord` | sourceText, translatedText, sourceLang, targetLang, createdAt, sourceType | Translation history |
| `OcrSession` | imagePath, rawOcrText, detectedLanguage, confidence, status | OCR capture log |
| `AudioCache` | textHash, textContent, audioFilePath, voiceId | Cached TTS audio files |
| `UserPreferences` | key/value pairs | User settings persistence |
| `OfflineModel` | modelId, type, languageCode, version, isDownloaded | Offline model registry |

## Non-Goals (v1)

- Sign language recognition
- Video translation or subtitling
- Website / full-document translation
- Real-time simultaneous interpretation
- Rare or dialect language support
- Emoji, mixed-language, special characters in text input
- Blurry / skewed / handwritten text in OCR
- Background noise cancellation in speech input

## Acceptance Criteria

| ID | Feature | Condition | Pass | Fail |
|---|---|---|---|---|
| AC-1 | Text Translation | Translate text between any of 10+ supported language pairs | Result displayed within 2s with >95% accuracy | Wrong translation, timeout >5s, or language not supported |
| AC-2 | Text Translation - Offline | Translate between top 10 language pairs without internet | Accurate translation returned with no network | Error message shown instead of fallback offline result |
| AC-3 | OCR Capture | Point camera at clean printed text in a supported language | Text recognized and translation overlay displayed within 3s | No text detected, wrong language detected, or overlay >5s |
| AC-4 | OCR - Error Handling | Capture blurry or skewed image | User sees "low confidence, retake" prompt (no crash) | App crashes or shows incorrect translation silently |
| AC-5 | Speech Input | Speak a phrase in a supported language in a quiet environment | English text displayed + English audio plays within 3s of stopping | Wrong transcription, no audio output, or timeout >6s |
| AC-6 | Audio Playback | Tap play on a translated result | Audio plays in English at normal speed | No audio, wrong language, distorted speech |
| AC-7 | Audio Controls | Adjust speed slider | Audio playback rate changes accordingly (0.5x-2x) | Speed does not change or app crashes |
| AC-8 | History | Complete any translation | Entry saved in history with source text, translation, timestamp | History empty or entry missing fields |
| AC-9 | Settings | Change source/target language defaults | New defaults applied to all translation screens | Defaults not persisted or not applied |
| AC-10 | Offline Models | Download offline model for a language pair | Model downloads and translation works offline | Download fails silently or offline falls back to error |

## Verification Plan

### Phase 1: Automated Tests

| Type | Scope | Command |
|---|---|---|
| Unit tests | Service layer (TranslationService, OcrService, AsrService, TtsService) | `flutter test test/services/` |
| Widget tests | Each screen in isolation | `flutter test test/widgets/` |
| Integration tests | End-to-end flows (translate -> history, camera -> OCR -> translate) | `flutter test test/integration/` |

### Phase 2: Manual QA Checklist

| # | Scenario | Steps | Expected |
|---|---|---|---|
| M-1 | Text translate online | Type "Hello" -> Spanish -> tap Translate | "Hola" displayed |
| M-2 | Text translate offline | Airplane mode -> translate top-10 pair | Result without error |
| M-3 | Camera capture | Point at printed sign -> wait for overlay | Translation visible on screen |
| M-4 | Speech -> English | Tap mic -> say "Bonjour" -> stop | "Hello" displayed + audio plays |
| M-5 | Speed control | Play translation -> drag speed to 2x | Audio plays at double speed |

### Pre-Commit Gate

```bash
flutter analyze && dart format --check . && flutter test
```
