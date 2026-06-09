# Translator Mobile App — Product Scope

## Product Vision

A mobile translation app that breaks language barriers through text translation, visual OCR, and speech-to-text with English audio output.

---

## Feature Scope

### 1. Text Translation

| Aspect | Detail |
|---|---|
| **Description** | Translate text between any supported language pair |
| **Input** | Typed or pasted text |
| **Language support** | 10+ languages |
| **Auto-detect** | Auto-detect source language or manual selection |
| **Offline** | Top 10 language pairs via on-device ML Kit |
| **Out of scope (v1)** | Emoji, mixed-language input, special characters, URLs |

### 2. Read Foreign Messages (OCR + Translation)

| Aspect | Detail |
|---|---|
| **Description** | Camera-based text capture with translation overlay |
| **Input** | Live camera feed or imported image from gallery |
| **Language support** | 10+ languages for OCR |
| **Output** | Translated text overlaid on image or side-by-side view |
| **Out of scope (v1)** | Blurry images, skewed text, handwritten text, low light, multiple languages in one image |

### 3. Foreign Text → English Audio

| Aspect | Detail |
|---|---|
| **Description** | Convert foreign text to English speech |
| **Input** | Typed/pasted foreign text or text captured via OCR (feature 2) |
| **Output** | English audio playback + displayed English text |
| **Playback controls** | Play/pause, speed (0.5x–2x), download audio |
| **Voice options** | Male/female, multiple English accents |
| **Out of scope (v1)** | Very long text chunking, abbreviations/numerals pronunciation |

### 4. Listen & Translate (Speech → English Audio)

| Aspect | Detail |
|---|---|
| **Description** | Microphone captures foreign speech, transcribes, translates to English, and plays English audio |
| **Input** | Live microphone audio |
| **Output** | English text displayed + English audio played back |
| **Modes** | Listen mode (single-direction), Conversation mode (two-way tap-to-talk) |
| **Out of scope (v1)** | Background noise handling, multiple speakers, overlapping speech, strong accents, hesitations/fillers, code-switching |

---

## Technical Stack

| Layer | Primary (Cloud) | Fallback (Offline) |
|---|---|---|
| **Framework** | Flutter | — |
| **Text Translation** | Google Cloud Translation API | Google ML Kit (10 language pairs) |
| **OCR** | Google ML Kit (on-device) | — |
| **ASR (Speech-to-Text)** | Google Speech-to-Text | Google ML Kit |
| **TTS (English Audio)** | Azure TTS (Neural) | OS-level TTS |

---

## Success Metrics

- Translation accuracy > 95% for top 10 language pairs

---

## Constraints (v1)

| Constraint | Detail |
|---|---|
| **Real-time interpretation** | Not real-time simultaneous interpretation (lag expected) |
| **Source audio** | Not preserving source audio characteristics (voice, emotion, tone) |
| **Rare/dialect languages** | Not handling rare/dialect languages confidently |

---

## Out of Scope (v1)

- Sign language recognition
- Video translation / subtitling
- Multi-speaker diarization
- Website translation
- Image-to-image translation within documents
- Offline ASR beyond on-device capabilities
- Conversation history export (PDF, SRT)
- Emoji, mixed-language input, special characters, URLs (text translation)
- Blurry images, skewed text, handwritten text, low light, multi-language images (OCR)
- Long text chunking, abbreviations/numerals pronunciation (TTS)
- Background noise, multiple speakers, overlapping speech, strong accents, hesitations/fillers, code-switching (ASR)

---

## Platforms

- iOS 16+ / Android 13+ (v1)
- SwiftUI (iOS) / Jetpack Compose (Android) — or Flutter cross-platform
