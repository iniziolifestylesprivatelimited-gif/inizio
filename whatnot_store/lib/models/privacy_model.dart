class PrivacyModel {
  final String id;
  final String content;
  final DateTime updatedAt;

  PrivacyModel({
    required this.id,
    required this.content,
    required this.updatedAt,
  });

  factory PrivacyModel.fromJson(Map<String, dynamic> json) {
    return PrivacyModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
