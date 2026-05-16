class TermsModel {
  final String id;
  final String content;
  final DateTime updatedAt;

  TermsModel({
    required this.id,
    required this.content,
    required this.updatedAt,
  });

  factory TermsModel.fromJson(Map<String, dynamic> json) {
    return TermsModel(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }
}
