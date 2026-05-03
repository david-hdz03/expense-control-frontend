class User {
  final int id;
  final String name;
  final String email;
  final bool isActive;
  final String currencyCode;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.isActive,
    required this.currencyCode,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
      currencyCode: json['currency_code'] as String? ?? 'USD',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
