class OfflineModel {
  final String modelId;
  final String modelType;
  final String languageCode;
  final String version;
  final double sizeMb;
  final bool isDownloaded;
  final DateTime lastUpdated;

  OfflineModel({
    required this.modelId,
    required this.modelType,
    required this.languageCode,
    required this.version,
    required this.sizeMb,
    this.isDownloaded = false,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'modelId': modelId,
    'modelType': modelType,
    'languageCode': languageCode,
    'version': version,
    'sizeMb': sizeMb,
    'isDownloaded': isDownloaded ? 1 : 0,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory OfflineModel.fromJson(Map<String, dynamic> json) => OfflineModel(
    modelId: json['modelId'] as String,
    modelType: json['modelType'] as String,
    languageCode: json['languageCode'] as String,
    version: json['version'] as String,
    sizeMb: (json['sizeMb'] as num).toDouble(),
    isDownloaded: (json['isDownloaded'] as int) == 1,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
  );

  OfflineModel copyWith({
    String? modelId,
    String? modelType,
    String? languageCode,
    String? version,
    double? sizeMb,
    bool? isDownloaded,
    DateTime? lastUpdated,
  }) => OfflineModel(
    modelId: modelId ?? this.modelId,
    modelType: modelType ?? this.modelType,
    languageCode: languageCode ?? this.languageCode,
    version: version ?? this.version,
    sizeMb: sizeMb ?? this.sizeMb,
    isDownloaded: isDownloaded ?? this.isDownloaded,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );

  @override
  String toString() => 'OfflineModel($modelType:$languageCode v$version)';
}
