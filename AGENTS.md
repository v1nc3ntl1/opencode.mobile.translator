# AGENTS.md — Translator Mobile App

## Install

```bash
flutter pub get
```

## Run

```bash
# On connected device / emulator
flutter run

# Web debug
flutter run -d chrome

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios
```

## Test / Check

```bash
# Run all tests
flutter test

# Static analysis
flutter analyze

# Format check
dart format --check .

# Combined pre-commit
flutter analyze && dart format --check . && flutter test
```

## Important Folders

| Path | Purpose |
|---|---|
| `lib/` | App source code |
| `lib/screens/` | UI screens (Translate, OCR, Speech, Audio, Settings) |
| `lib/viewmodels/` | ViewModels per screen |
| `lib/services/` | Core services (Translation, OCR, ASR, TTS) |
| `lib/orchestrators/` | Flow orchestrators (Translate, OcrTranslate, SpeechTranslate) |
| `lib/models/` | Entity models |
| `lib/core/` | Shared core (LanguageManager, CacheManager, OfflineManager, ConnectivityMonitor) |
| `lib/widgets/` | Reusable UI widgets |
| `test/` | Unit, widget, and integration tests |
| `assets/` | Static assets (images, fonts, offline model references) |
| `android/` | Android platform config |
| `ios/` | iOS platform config |

## Flutter Commands

```bash
flutter create .                    # Scaffold project (if not exists)
flutter pub add <package>           # Add dependency
flutter pub upgrade                 # Upgrade all dependencies
flutter clean                       # Clean build artifacts
flutter gen-l10n                    # Generate localizations
```

## Environment Variables (Dart Define)

Use `--dart-define` for all secrets and environment configuration.
Never hardcode API keys or secrets in source code.

```bash
# Running locally
flutter run --dart-define=GOOGLE_TRANSLATE_API_KEY=<key> \
            --dart-define=GOOGLE_ASR_API_KEY=<key> \
            --dart-define=AZURE_TTS_API_KEY=<key> \
            --dart-define=AZURE_TTS_REGION=<region>

# CI/CD builds
flutter build apk --dart-define=GOOGLE_TRANSLATE_API_KEY=$GT_KEY \
                  --dart-define=GOOGLE_ASR_API_KEY=$GA_KEY \
                  --dart-define=AZURE_TTS_API_KEY=$AT_KEY \
                  --dart-define=AZURE_TTS_REGION=$AT_REGION
```

### Required Dart Define Variables

| Variable | Description |
|---|---|
| `GOOGLE_TRANSLATE_API_KEY` | Google Cloud Translation API key |
| `GOOGLE_ASR_API_KEY` | Google Speech-to-Text API key |
| `AZURE_TTS_API_KEY` | Azure TTS subscription key |
| `AZURE_TTS_REGION` | Azure TTS region (e.g. `eastus`) |

Access in code via:

```dart
const apiKey = String.fromEnvironment('GOOGLE_TRANSLATE_API_KEY');
```

## Secret-Handling Rules

1. **Never commit secrets** — `--dart-define` values must never appear in source files
2. **No `.env` files** — all config passed via `--dart-define` at build/run time
3. **CI/CD** — inject secrets via GitHub Actions secrets or equivalent
4. **Documentation** — list required vars in AGENTS.md only; never paste real values
5. **Key rotation** — if a key is accidentally committed, rotate it immediately

## Verification Expectations

Before every commit, run:

```bash
flutter analyze && dart format --check . && flutter test
```

| Check | Must Pass |
|---|---|
| `flutter analyze` | Zero errors, zero warnings |
| `dart format --check .` | All files formatted |
| `flutter test` | All tests green |
