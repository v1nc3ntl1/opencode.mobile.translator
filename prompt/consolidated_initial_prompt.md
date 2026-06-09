# Consolidated Initial Prompt — Translator Mobile App

> Use this prompt to re-implement the entire translator mobile app from scratch.
> Save as `prompt/consolidated_initial_prompt.md` in the project root.

---

## 1. Product Scope

Define a translator mobile app with these 4 core features:

1. **Text Translation** — Translate from one language to another
2. **Read Foreign Messages (OCR + Translation)** — Read messages in a different language via camera
3. **Foreign Text → English Audio** — Translate other language text to English audio (TTS)
4. **Listen & Translate (Speech → English Audio)** — Listen to foreign speech and get English translation + audio

### Feature Details

#### 1. Text Translation
- Support: 10+ languages for text translation
- Out of scope (v1): emoji, mixed-language input, special characters, URLs
- Offline: top 10 language pairs via on-device ML Kit

#### 2. Read Foreign Messages (OCR + Translation)
- Support: 10+ languages for OCR
- Out of scope (v1): blurry images, skewed text, handwritten text, low light, multiple languages in one image

#### 3. Foreign Text → English Audio
- Edge cases excluded (v1): very long text (chunking), abbreviations/numerals pronunciation

#### 4. Listen & Translate (Speech → English Audio)
- Edge cases excluded (v1): background noise, multiple speakers, overlapping speech, strong accents, hesitations/fillers, code-switching

### Constraints (v1)
- Not real-time simultaneous interpretation (lag expected)
- Not preserving source audio characteristics (voice, emotion, tone)
- Not handling rare/dialect languages confidently

---

## 2. Technical Stack (Choice B — Balanced)

| Layer | Primary (Cloud) | Fallback (Offline) |
|---|---|---|
| **Framework** | Flutter (cross-platform) | — |
| **Text Translation** | Google Cloud Translation API | Google ML Kit (10 language pairs) |
| **OCR** | Google ML Kit Text Recognition (on-device) | — |
| **ASR (Speech-to-Text)** | Google Speech-to-Text | Google ML Kit Speech (on-device) |
| **TTS (English Audio)** | Azure TTS (Neural) | OS-level TTS (AVSpeech / Android TTS) |
| **Local storage** | sembast (cross-platform: web, mobile, desktop) | — |
| **Cache** | In-memory LRU cache | — |
| **State Management** | Provider (ChangeNotifier) | — |
| **Settings** | SharedPreferences | — |

**Fallback hierarchy**: Cache → Offline ML Kit → Cloud API

---

## 3. Version History (from this implementation)

| Commit | Description |
|---|---|
| `402b8e9` | Initial commit: architecture and scope docs |
| `0a6acbc` | Add AGENTS.md and SPEC.md with full project conventions |
| `5dbf812` | Implement Task 1 Text translation Core |
| `33baefd` | Ignore .metadata and untrack committed file |
| `6705b97` | Fix translation page not showing up (sqflite → sembast) |

### Key Decisions Made During Implementation

1. **Database**: Started with `sqflite`, but switched to `sembast` because `sqflite` doesn't work on Flutter web. Since the app runs on Chrome for debugging, `sembast` (in-memory) was used for cross-platform compatibility.
2. **Project name**: `translator_app` (valid Dart package name, unlike `opencode.playground.3`)
3. **Organization**: `com.translator`

---

## 4. Architecture

### Layers
```
Presentation (Screens)
    ↓
ViewModels (ChangeNotifier + Provider)
    ↓
Orchestrators (business logic, cache→offline→cloud decision tree)
    ↓
Service Layer (TextTranslationService, OcrService, AsrService, TtsService)
    ↓
Data Layer (sembast DB, in-memory Cache, SharedPreferences)
```

### Entities
- `Language` — code, name, nativeName, supported feature flags, offlineModelAvailable
- `TranslationRecord` — id, sourceText, translatedText, sourceLanguage, targetLanguage, createdAt, sourceType, isFavorite, confidenceScore
- `OcrSession` — id, imagePath, rawOcrText, detectedLanguage, confidence, status
- `AudioCache` — id, textHash, textContent, audioFilePath, voiceId, durationMs
- `UserPreferences` — key/value pairs
- `OfflineModel` — modelId, modelType, languageCode, version, sizeMb, isDownloaded

### Vertical Slices

| Slice | Feature | Dependencies |
|---|---|---|
| 1 | Text Translation (Core) | None (foundation) |
| 2 | OCR Translation | Slice 1 |
| 3 | Speech → English Audio | Slice 1 |
| 4 | Settings, Offline Models & History | Slices 1, 2, 3 |
| 5 | Conversation Mode & Polish | All above |

---

## 5. Implementation Tasks (per Slice)

### Task 1: Text Translation Core (CURRENT)

**Steps**:
1. Scaffold Flutter project (`flutter create . --project-name=translator_app --org com.translator --platforms=android,ios`)
2. Add dependencies: `provider`, `sembast`, `sembast_web`, `path_provider`, `connectivity_plus`, `http`, `google_mlkit_translation`, `path`
3. Define all entity models (6 files under `lib/models/`)
4. Implement `DatabaseHelper` (sembast in-memory for web compatibility)
5. Implement `LanguageManager` (12 supported languages with feature flags)
6. Implement `CacheManager` (in-memory LRU, max 200 entries)
7. Implement `ConnectivityMonitor` (online/offline detection via connectivity_plus)
8. Implement `TextTranslationService` (Google Cloud API online + ML Kit offline fallback)
9. Implement `TranslateOrchestrator` (cache → offline → cloud decision tree)
10. Implement `TranslationViewModel` (ChangeNotifier state management)
11. Build `TranslateScreen` UI with `LanguagePicker` + `TranslationOutput` widgets
12. Wire up `main.dart` and `app.dart`
13. Write unit/widget tests (5 test files)
14. Verify: `flutter analyze` zero errors, `dart format --set-exit-if-changed .` passes, `flutter test` all green

**Dependencies**: None

**Acceptance Criteria**: AC-1, AC-2, AC-8

### Task 2: OCR Translation (PENDING)

**Steps**:
1. Add camera/gallery dependencies (camera, image_picker, google_mlkit_text_recognition)
2. Implement `OcrService` (ML Kit Text Recognition, on-device)
3. Implement `OcrTranslateOrchestrator` (image → OCR → translate)
4. Implement `OcrViewModel`
5. Build `OcrScreen` (camera preview, gallery import, translation overlay, retake prompt)
6. Persist `OcrSession` to sembast
7. Write tests

**Dependencies**: Task 1

**Acceptance Criteria**: AC-3, AC-4

### Task 3: Speech → English Audio (PENDING)

**Steps**:
1. Add speech/TTS dependencies (speech_to_text, audioplayers, google_mlkit_speech, azure_speech)
2. Implement `AsrService` (Google STT cloud + ML Kit offline)
3. Implement `TtsService` (Azure TTS cloud + OS-level fallback)
4. Implement `SpeechTranslateOrchestrator` (speech → ASR → translate → TTS)
5. Implement `SpeechViewModel` + `AudioViewModel`
6. Build `SpeechScreen` (mic, live captions) + `AudioPlaybackScreen` (play/pause, speed 0.5x–2x)
7. Persist `AudioCache`
8. Write tests

**Dependencies**: Task 1

**Acceptance Criteria**: AC-5, AC-6, AC-7

### Task 4: Settings, Offline Models & History (PENDING)

**Steps**:
1. Implement `OfflineManager` (model download/delete/status)
2. Implement `OfflineSyncManager` + `ConnectivityMonitor` integration
3. Implement `SettingsViewModel` + `HistoryViewModel`
4. Build `SettingsScreen` (language prefs, voice prefs, model management)
5. Build `HistoryScreen` (list, filter by source type, favorites toggle)
6. Wire `UserPreferences` persistence
7. Write tests

**Dependencies**: Tasks 1, 2, 3

**Acceptance Criteria**: AC-9, AC-10

### Task 5: Conversation Mode & Polish (PENDING)

**Steps**:
1. Build `ConversationScreen` (two-way alternating speech, split-screen)
2. Build `ConversationBubble` widget
3. Add error/loading/empty state widgets
4. Accessibility audit (screen reader labels, contrast)
5. Performance optimization (lazy loading, image compression)
6. Full integration tests for all flows
7. Manual QA checklist

**Dependencies**: Tasks 1, 2, 3, 4

**Acceptance Criteria**: All AC-1 through AC-10

---

## 6. Acceptance Criteria

| ID | Feature | Condition | Pass | Fail |
|---|---|---|---|---|
| AC-1 | Text Translation | Translate text between any of 10+ supported language pairs | Result displayed within 2s with >95% accuracy | Wrong translation, timeout >5s, or language not supported |
| AC-2 | Text Translation — Offline | Translate between top 10 language pairs without internet | Accurate translation returned with no network | Error message shown instead of fallback offline result |
| AC-3 | OCR Capture | Point camera at clean printed text in a supported language | Text recognized and translation overlay displayed within 3s | No text detected, wrong language detected, or overlay >5s |
| AC-4 | OCR — Error Handling | Capture blurry or skewed image | User sees "low confidence, retake" prompt (no crash) | App crashes or shows incorrect translation silently |
| AC-5 | Speech Input | Speak a phrase in a supported language in a quiet environment | English text displayed + English audio plays within 3s of stopping | Wrong transcription, no audio output, or timeout >6s |
| AC-6 | Audio Playback | Tap play on a translated result | Audio plays in English at normal speed | No audio, wrong language, distorted speech |
| AC-7 | Audio Controls | Adjust speed slider | Audio playback rate changes accordingly (0.5x–2x) | Speed does not change or app crashes |
| AC-8 | History | Complete any translation | Entry saved in history with source text, translation, timestamp | History empty or entry missing fields |
| AC-9 | Settings | Change source/target language defaults | New defaults applied to all translation screens | Defaults not persisted or not applied |
| AC-10 | Offline Models | Download offline model for a language pair | Model downloads and translation works offline | Download fails silently or offline falls back to error |

---

## 7. Environment Variables (Dart Define)

```bash
flutter run --dart-define=GOOGLE_TRANSLATE_API_KEY=<key> \
            --dart-define=GOOGLE_ASR_API_KEY=<key> \
            --dart-define=AZURE_TTS_API_KEY=<key> \
            --dart-define=AZURE_TTS_REGION=<region>
```

| Variable | Description |
|---|---|
| `GOOGLE_TRANSLATE_API_KEY` | Google Cloud Translation API key |
| `GOOGLE_ASR_API_KEY` | Google Speech-to-Text API key |
| `AZURE_TTS_API_KEY` | Azure TTS subscription key |
| `AZURE_TTS_REGION` | Azure TTS region (e.g. `eastus`) |

---

## 8. Pre-Commit Gate

```bash
flutter analyze && dart format --set-exit-if-changed . && flutter test
```

| Check | Must Pass |
|---|---|
| `flutter analyze` | Zero errors, zero warnings |
| `dart format --set-exit-if-changed .` | All files formatted |
| `flutter test` | All tests green |

---

## 9. Files to Create (Task 1)

```
lib/main.dart
lib/app.dart
lib/models/language.dart
lib/models/translation_record.dart
lib/models/audio_cache.dart
lib/models/user_preferences.dart
lib/models/offline_model.dart
lib/models/ocr_session.dart
lib/core/database_helper.dart
lib/core/language_manager.dart
lib/core/cache_manager.dart
lib/core/connectivity_monitor.dart
lib/services/text_translation_service.dart
lib/orchestrators/translate_orchestrator.dart
lib/viewmodels/translation_viewmodel.dart
lib/screens/translate_screen.dart
lib/widgets/language_picker.dart
lib/widgets/translation_output.dart
test/core/cache_manager_test.dart
test/services/text_translation_service_test.dart
test/orchestrators/translate_orchestrator_test.dart
test/viewmodels/translation_viewmodel_test.dart
test/widgets/translate_screen_test.dart
test/widget_test.dart
```

---

## 10. Git Setup

```bash
git init
echo "*.env" >> .gitignore
echo ".metadata" >> .gitignore     # Flutter auto-generated, changes on every create
git add -A
git commit -m "Initial commit"
git remote add origin <repo-url>
git push -u origin master
```
