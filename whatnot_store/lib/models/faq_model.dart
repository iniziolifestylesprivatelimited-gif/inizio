class FaqModel {
  final String id;
  final String question;
  final String answer;
  final DateTime createdAt;

  FaqModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.createdAt,
  });

  factory FaqModel.fromJson(Map<String, dynamic> json) {
    return FaqModel(
      id: json['_id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
