class OcrSession {
  final String id;
  final String imagePath;
  final String rawOcrText;
  final String detectedLanguage;
  final double confidence;
  final DateTime capturedAt;
  final String status;

  OcrSession({
    required this.id,
    required this.imagePath,
    this.rawOcrText = '',
    this.detectedLanguage = '',
    this.confidence = 0.0,
    DateTime? capturedAt,
    this.status = 'pending',
  }) : capturedAt = capturedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'rawOcrText': rawOcrText,
    'detectedLanguage': detectedLanguage,
    'confidence': confidence,
    'capturedAt': capturedAt.toIso8601String(),
    'status': status,
  };

  factory OcrSession.fromJson(Map<String, dynamic> json) => OcrSession(
    id: json['id'] as String,
    imagePath: json['imagePath'] as String,
    rawOcrText: json['rawOcrText'] as String,
    detectedLanguage: json['detectedLanguage'] as String,
    confidence: (json['confidence'] as num).toDouble(),
    capturedAt: DateTime.parse(json['capturedAt'] as String),
    status: json['status'] as String,
  );

  @override
  String toString() => 'OcrSession(status: $status, confidence: $confidence)';
}
