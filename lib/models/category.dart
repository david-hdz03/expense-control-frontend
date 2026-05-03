class Category {
  final int id;
  final String name;
  final bool isDefault;

  const Category({
    required this.id,
    required this.name,
    required this.isDefault,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      isDefault: json['is_default'] as bool,
    );
  }
}
