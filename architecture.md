# Translator Mobile App — Architecture

## Chosen Stack — Balanced (Choice B)

| Layer | Technology | Rationale |
|---|---|---|
| **Framework** | Flutter | Cross-platform, single codebase, mature ML Kit plugins |
| **Text Translation (cloud)** | Google Cloud Translation API | Best accuracy for 10+ languages, largest language coverage |
| **Text Translation (offline)** | Google ML Kit (on-device) | Free, low latency, covers top 10 language pairs offline |
| **OCR** | Google ML Kit Text Recognition (on-device) | Free, fast, supports 60+ scripts, no cloud dependency |
| **ASR (cloud)** | Google Speech-to-Text | Best accuracy across 125+ languages, real-time streaming |
| **ASR (offline)** | Google ML Kit Speech (on-device) | Free fallback for top 5 languages |
| **TTS (cloud)** | Azure TTS (Neural) | Most natural English voices, fine-grained SSML control |
| **TTS (offline)** | OS-level TTS (AVSpeech / Android TTS) | Free, on-device fallback when offline |
| **Local storage** | SQLite | Reliable, zero-config, well-supported in Flutter |
| **Cache** | In-memory LRU cache | Minimizes repeat cloud calls, improves latency |
| **Settings** | SharedPreferences | Simple key-value persistence for user prefs |

**Fallback hierarchy**: Cache → Offline ML Kit → Cloud API (see §4 for decision tree).

---

## 1. System Architecture

```mermaid
graph TB
    %% ── Presentation Layer ──
    subgraph Presentation["Presentation Layer"]
        TranslateUI["Text Translation Screen"]
        OcrUI["OCR / Camera Screen"]
        SpeechUI["Speech Input Screen"]
        AudioUI["Audio Playback Screen"]
        SettingsUI["Settings Screen"]
    end

    %% ── Application / Business Logic Layer ──
    subgraph AppLogic["Application Layer"]
        TranslateVM["TranslationViewModel"]
        OcrVM["OcrViewModel"]
        SpeechVM["SpeechViewModel"]
        AudioVM["AudioViewModel"]
        SyncMgr["OfflineSyncManager"]
        LangMgr["LanguageManager"]
    end

    %% ── Service Layer ──
    subgraph Services["Service Layer"]
        direction TB
        subgraph CoreServices["Core Services"]
            TextTranslator["TextTranslationService"]
            OcrService["OcrService"]
            AsrService["AsrService"]
            TtsService["TtsService"]
        end
        subgraph Orchestration["Orchestration"]
            TranslateOrch["TranslateOrchestrator<br/>text -> translate"]
            OcrOrch["OcrTranslateOrchestrator<br/>image -> ocr -> translate"]
            SpeechOrch["SpeechTranslateOrchestrator<br/>speech -> asr -> translate -> tts"]
        end
    end

    %% ── Data / Persistence Layer ──
    subgraph Data["Data Layer"]
        LocalDB[(Local SQLite DB)]
        Cache[(Translation Cache)]
        OfflineModels["Offline ML Models<br/>(ML Kit bundles)"]
        Prefs["SharedPreferences<br/>(user settings)"]
    end

    %% ── External Cloud APIs ──
    subgraph External["External Cloud APIs"]
        GoogleTranslate["Google Cloud Translation API"]
        GoogleASR["Google Speech-to-Text"]
        AzureTTS["Azure TTS (Neural)"]
    end

    %% ── Connections ──
    TranslateUI --> TranslateVM
    OcrUI --> OcrVM
    SpeechUI --> SpeechVM
    AudioUI --> AudioVM
    SettingsUI --> LangMgr

    TranslateVM --> TranslateOrch
    OcrVM --> OcrOrch
    SpeechVM --> SpeechOrch
    AudioVM --> TtsService

    TranslateOrch --> TextTranslator
    OcrOrch --> OcrService
    OcrOrch --> TextTranslator
    SpeechOrch --> AsrService
    SpeechOrch --> TextTranslator
    SpeechOrch --> TtsService

    TextTranslator --> OfflineModels
    TextTranslator --> GoogleTranslate
    OcrService --> OfflineModels
    AsrService --> OfflineModels
    AsrService --> GoogleASR
    TtsService --> OfflineModels
    TtsService --> AzureTTS

    TranslateOrch --> LocalDB
    OcrOrch --> LocalDB
    SpeechOrch --> LocalDB
    TextTranslator --> Cache
    OcrService --> Cache
    SyncMgr --> OfflineModels
    SyncMgr --> LocalDB
    LangMgr --> Prefs
```

---

## 2. Entity Architecture (Data Model)

```mermaid
erDiagram
    Language {
        string code PK "e.g. 'es', 'fr'"
        string name "e.g. 'Spanish'"
        string nativeName "e.g. 'Espanol'"
        bool isSourceSupported
        bool isTargetSupported
        bool isOcrSupported
        bool isAsrSupported
        bool isTtsSupported
        bool offlineModelAvailable
    }

    TranslationRecord {
        uuid id PK
        string sourceText
        string translatedText
        string sourceLanguage FK
        string targetLanguage FK
        datetime createdAt
        datetime accessedAt
        string sourceType "manual | ocr | speech"
        bool isFavorite
        float confidenceScore
    }

    OcrSession {
        uuid id PK
        string imagePath
        string rawOcrText
        string detectedLanguage
        float confidence
        datetime capturedAt
        string status "pending | completed | failed"
    }

    AudioCache {
        uuid id PK
        string textHash UK
        string textContent
        string audioFilePath
        string voiceId
        float durationMs
        datetime generatedAt
    }

    UserPreferences {
        string key PK
        string value
    }

    OfflineModel {
        string modelId PK
        string modelType "translation | ocr | asr | tts"
        string languageCode FK
        string version
        float sizeMb
        bool isDownloaded
        datetime lastUpdated
    }

    Language ||--o{ TranslationRecord : "source language"
    Language ||--o{ TranslationRecord : "target language"
    Language ||--o{ OfflineModel : "has model"
    TranslationRecord ||--o{ AudioCache : "has cache"
    OcrSession ||--|| TranslationRecord : "produces"
```

---

## 3. Sequence Diagrams — Core Flows

### 3a. Text Translation Flow

```mermaid
sequenceDiagram
    actor User
    participant UI as TranslateScreen
    participant VM as TranslateViewModel
    participant Orch as TranslateOrchestrator
    participant Svc as TextTranslationService
    participant Cache as TranslationCache
    participant Cloud as Google Cloud Translation API
    participant Offline as Offline ML Models

    User->>UI: Types/Pastes text
    UI->>VM: translate(sourceText, sourceLang, targetLang)
    VM->>Orch: execute(request)
    Orch->>Cache: lookup(sourceText, sourceLang, targetLang)
    alt Cache Hit
        Cache-->>Orch: cached result
    else Cache Miss
        Orch->>Svc: translate(request)
        alt Offline Available
            Svc->>Offline: translate offline
            Offline-->>Svc: translated text
        else Online Required
            Svc->>Cloud: POST /translate
            Cloud-->>Svc: translated text
        end
        Svc-->>Orch: result
        Orch->>Cache: store(sourceText, targetLang, result)
    end
    Orch-->>VM: TranslationResult(text, confidence)
    VM->>VM: save to history (TranslationRecord)
    VM-->>UI: display translated text
    UI-->>User: Shows translation
```

### 3b. OCR + Translation Flow

```mermaid
sequenceDiagram
    actor User
    participant UI as OcrScreen
    participant VM as OcrViewModel
    participant Orch as OcrTranslateOrchestrator
    participant OcrSvc as OcrService
    participant TransSvc as TextTranslationService
    participant DB as LocalDB

    User->>UI: Captures/Imports image
    UI->>VM: processImage(image)
    VM->>OcrSvc: recognizeText(image)
    OcrSvc->>OcrSvc: preprocess (crop, deskew, enhance)
    OcrSvc->>OcrSvc: run ML Kit Text Recognition
    OcrSvc-->>VM: OcrResult(rawText, confidence, detectedLang)

    VM->>DB: save OcrSession
    alt confidence < threshold
        VM-->>UI: "Low confidence, retake?"
    else confidence >= threshold
        VM->>Orch: translateOcrText(rawText, detectedLang, "en")
        Orch->>TransSvc: translate(request)
        TransSvc-->>Orch: translatedText
        Orch-->>VM: result
        VM->>DB: save TranslationRecord
        VM-->>UI: show overlay/side-by-side translation
    end
```

### 3c. Speech -> English Audio Flow

```mermaid
sequenceDiagram
    actor User
    participant UI as SpeechScreen
    participant VM as SpeechViewModel
    participant Orch as SpeechTranslateOrchestrator
    participant AsrSvc as AsrService
    participant TransSvc as TextTranslationService
    participant TtsSvc as TtsService
    participant Audio as AudioCache

    User->>UI: Starts mic recording
    UI->>VM: startListening(sourceLang)
    loop Real-time streaming
        VM->>AsrSvc: streamAudioChunk()
        AsrSvc-->>VM: interimText
        VM-->>UI: show interim (live captions)
    end
    User->>UI: Stops recording
    UI->>VM: stopAndTranslate()

    VM->>AsrSvc: finalizeTranscript()
    AsrSvc-->>VM: fullTranscript

    VM->>Orch: execute(transcript)
    Orch->>TransSvc: translate(transcript, detectedLang, "en")
    TransSvc-->>Orch: translatedText

    Orch->>TtsSvc: generateSpeech(translatedText, "en")
    alt Cached
        Audio-->>TtsSvc: cached audio
    else Not Cached
        TtsSvc->>TtsSvc: run Azure TTS / OS TTS
        TtsSvc->>Audio: cache audio
    end
    TtsSvc-->>Orch: audioFilePath
    Orch-->>VM: SpeechResult(translatedText, audioPath)

    VM->>VM: save to history
    VM-->>UI: show English text + play audio
    UI-->>User: Displays text + plays English audio
```

---

## 4. Offline vs Online Decision Tree

```mermaid
flowchart TD
    A[User Action: translate / ocr / asr / tts] --> B{Device Online?}
    B -->|Yes| C{Cached Result?}
    B -->|No| D{Offline Model<br/>Available?}

    C -->|Yes| E[Return cached result]
    C -->|No| F[Call Cloud API]

    D -->|Yes| G[Run on-device ML Kit]
    D -->|No| H[Show Error:<br/>'Requires internet']

    F --> I[Store result in cache]
    I --> J[Return result]

    G --> K[Store result in cache]
    K --> J
```

---

## 5. Component Dependency Map

```mermaid
graph LR
    subgraph Features["Feature Modules"]
        TextTrans["Text Translation"]
        OcrTrans["OCR Translation"]
        SpeechTrans["Speech Translation"]
        AudioPlay["Audio Playback"]
    end

    subgraph SharedCore["Shared Core"]
        LangManager["Language Manager"]
        HistoryMgr["History Manager"]
        CacheMgr["Cache Manager"]
        OfflineMgr["Offline Model Manager"]
        Connectivity["Connectivity Monitor"]
    end

    subgraph ServiceLayer["Service Layer"]
        Trans["TextTranslationService"]
        Ocr["OcrService"]
        Asr["AsrService"]
        Tts["TtsService"]
    end

    TextTrans --> Trans
    TextTrans --> LangManager
    TextTrans --> HistoryMgr
    TextTrans --> CacheMgr

    OcrTrans --> Ocr
    OcrTrans --> Trans
    OcrTrans --> LangManager
    OcrTrans --> HistoryMgr

    SpeechTrans --> Asr
    SpeechTrans --> Trans
    SpeechTrans --> Tts
    SpeechTrans --> LangManager
    SpeechTrans --> HistoryMgr

    AudioPlay --> Tts
    AudioPlay --> CacheMgr

    Trans --> OfflineMgr
    Trans --> Connectivity
    Ocr --> OfflineMgr
    Ocr --> Connectivity
    Asr --> OfflineMgr
    Asr --> Connectivity
    Tts --> OfflineMgr
    Tts --> Connectivity

    Trans --> CacheMgr
    Asr --> CacheMgr
    Tts --> CacheMgr
```

---

## 6. Scope Notes

| Feature | Languages | Offline | Excluded (v1) |
|---|---|---|---|
| Text Translation | 10+ | Top 10 pairs | Emoji, mixed-language, special chars, URLs |
| OCR + Translation | 10+ (OCR) | — | Blurry, skewed, handwritten, low light, multi-language images |
| Foreign Text -> English Audio | TTS: English only | — | Long text chunking, abbreviations/numerals |
| Speech -> English Audio | ASR: 10+ source | — | Background noise, multiple speakers, overlapping, strong accents, code-switching |
