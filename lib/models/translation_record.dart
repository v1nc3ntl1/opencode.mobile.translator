class TranslationRecord {
  final String id;
  final String sourceText;
  final String translatedText;
  final String sourceLanguage;
  final String targetLanguage;
  final DateTime createdAt;
  final DateTime accessedAt;
  final String sourceType;
  final bool isFavorite;
  final double confidenceScore;

  TranslationRecord({
    required this.id,
    required this.sourceText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    DateTime? createdAt,
    DateTime? accessedAt,
    this.sourceType = 'manual',
    this.isFavorite = false,
    this.confidenceScore = 1.0,
  }) : createdAt = createdAt ?? DateTime.now(),
       accessedAt = accessedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'sourceText': sourceText,
    'translatedText': translatedText,
    'sourceLanguage': sourceLanguage,
    'targetLanguage': targetLanguage,
    'createdAt': createdAt.toIso8601String(),
    'accessedAt': accessedAt.toIso8601String(),
    'sourceType': sourceType,
    'isFavorite': isFavorite ? 1 : 0,
    'confidenceScore': confidenceScore,
  };

  factory TranslationRecord.fromJson(Map<String, dynamic> json) =>
      TranslationRecord(
        id: json['id'] as String,
        sourceText: json['sourceText'] as String,
        translatedText: json['translatedText'] as String,
        sourceLanguage: json['sourceLanguage'] as String,
        targetLanguage: json['targetLanguage'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        accessedAt: DateTime.parse(json['accessedAt'] as String),
        sourceType: json['sourceType'] as String,
        isFavorite: (json['isFavorite'] as int) == 1,
        confidenceScore: (json['confidenceScore'] as num).toDouble(),
      );

  TranslationRecord copyWith({
    String? id,
    String? sourceText,
    String? translatedText,
    String? sourceLanguage,
    String? targetLanguage,
    DateTime? createdAt,
    DateTime? accessedAt,
    String? sourceType,
    bool? isFavorite,
    double? confidenceScore,
  }) => TranslationRecord(
    id: id ?? this.id,
    sourceText: sourceText ?? this.sourceText,
    translatedText: translatedText ?? this.translatedText,
    sourceLanguage: sourceLanguage ?? this.sourceLanguage,
    targetLanguage: targetLanguage ?? this.targetLanguage,
    createdAt: createdAt ?? this.createdAt,
    accessedAt: accessedAt ?? this.accessedAt,
    sourceType: sourceType ?? this.sourceType,
    isFavorite: isFavorite ?? this.isFavorite,
    confidenceScore: confidenceScore ?? this.confidenceScore,
  );

  @override
  String toString() =>
      'TranslationRecord($sourceLanguage->$targetLanguage: "$sourceText" => "$translatedText")';
}
