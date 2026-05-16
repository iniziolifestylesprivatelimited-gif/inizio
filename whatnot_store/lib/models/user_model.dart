class User {
  final String id;
  final String name;
  final String email;
  final bool isApproved;
  final String userId; // ✅ ADD THIS

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.isApproved,
    required this.userId, // ✅ ADD
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isApproved: json['isApproved'] ?? false,
      userId: json['userId'] ?? '', // ✅ ADD
    );
  }
}