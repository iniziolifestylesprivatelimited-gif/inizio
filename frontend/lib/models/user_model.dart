class User {
  final String id;
  final String name;
  final String email;
  final bool isApproved;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isApproved,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isApproved: json['isApproved'] ?? false,
    );
  }
}
