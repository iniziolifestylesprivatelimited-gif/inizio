class BannerModel {
  final String id;
  final String title;
  final String image;
  final String? link;
  final bool isActive;
  final String position;

  BannerModel({
    required this.id,
    required this.title,
    required this.image,
    this.link,
    required this.isActive,
    required this.position,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      link: json['link'],
      isActive: json['isActive'] ?? true,
      position: json['position'] ?? 'homepage',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'image': image,
      'link': link,
      'isActive': isActive,
      'position': position,
    };
  }
}
