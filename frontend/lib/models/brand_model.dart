class Brand {
  final String id;
  final String name;
  final String? description;
  final String? logo;
  final bool isActive;

  Brand({
    required this.id,
    required this.name,
    this.description,
    this.logo,
    required this.isActive,
  });

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      logo: json['logo'] ?? '',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'logo': logo,
      'isActive': isActive,
    };
  }
}
