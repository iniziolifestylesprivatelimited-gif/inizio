class Category {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final bool isActive;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.isActive,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'isActive': isActive,
    };
  }
}
