class AudioCache {
  final String id;
  final String textHash;
  final String textContent;
  final String audioFilePath;
  final String voiceId;
  final double durationMs;
  final DateTime generatedAt;

  AudioCache({
    required this.id,
    required this.textHash,
    required this.textContent,
    required this.audioFilePath,
    required this.voiceId,
    required this.durationMs,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'textHash': textHash,
    'textContent': textContent,
    'audioFilePath': audioFilePath,
    'voiceId': voiceId,
    'durationMs': durationMs,
    'generatedAt': generatedAt.toIso8601String(),
  };

  factory AudioCache.fromJson(Map<String, dynamic> json) => AudioCache(
    id: json['id'] as String,
    textHash: json['textHash'] as String,
    textContent: json['textContent'] as String,
    audioFilePath: json['audioFilePath'] as String,
    voiceId: json['voiceId'] as String,
    durationMs: (json['durationMs'] as num).toDouble(),
    generatedAt: DateTime.parse(json['generatedAt'] as String),
  );

  @override
  String toString() => 'AudioCache(textHash: $textHash)';
}
