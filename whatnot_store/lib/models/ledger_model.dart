class LedgerModel {
  final String id;
  final String title;
  final String fileUrl;
  final String createdAt;

  LedgerModel({
    required this.id,
    required this.title,
    required this.fileUrl,
    required this.createdAt,
  });

  factory LedgerModel.fromJson(Map<String, dynamic> json) {
    return LedgerModel(
      id: json['_id'],
      title: json['title'],
      fileUrl: json['fileUrl'],
      createdAt: json['createdAt'],
    );
  }
}
