class Language {
  final String code;
  final String name;
  final String nativeName;
  final bool isSourceSupported;
  final bool isTargetSupported;
  final bool isOcrSupported;
  final bool isAsrSupported;
  final bool isTtsSupported;
  final bool offlineModelAvailable;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
    this.isSourceSupported = true,
    this.isTargetSupported = true,
    this.isOcrSupported = false,
    this.isAsrSupported = false,
    this.isTtsSupported = false,
    this.offlineModelAvailable = false,
  });

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'nativeName': nativeName,
    'isSourceSupported': isSourceSupported ? 1 : 0,
    'isTargetSupported': isTargetSupported ? 1 : 0,
    'isOcrSupported': isOcrSupported ? 1 : 0,
    'isAsrSupported': isAsrSupported ? 1 : 0,
    'isTtsSupported': isTtsSupported ? 1 : 0,
    'offlineModelAvailable': offlineModelAvailable ? 1 : 0,
  };

  factory Language.fromJson(Map<String, dynamic> json) => Language(
    code: json['code'] as String,
    name: json['name'] as String,
    nativeName: json['nativeName'] as String,
    isSourceSupported: (json['isSourceSupported'] as int) == 1,
    isTargetSupported: (json['isTargetSupported'] as int) == 1,
    isOcrSupported: (json['isOcrSupported'] as int) == 1,
    isAsrSupported: (json['isAsrSupported'] as int) == 1,
    isTtsSupported: (json['isTtsSupported'] as int) == 1,
    offlineModelAvailable: (json['offlineModelAvailable'] as int) == 1,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Language && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Language($code: $name)';
}
