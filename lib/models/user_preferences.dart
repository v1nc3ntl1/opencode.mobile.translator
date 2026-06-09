class UserPreferences {
  final String key;
  final String value;

  const UserPreferences({required this.key, required this.value});

  Map<String, dynamic> toJson() => {'key': key, 'value': value};

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      UserPreferences(
        key: json['key'] as String,
        value: json['value'] as String,
      );

  @override
  String toString() => 'UserPreferences($key: $value)';
}
