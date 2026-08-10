class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? photoUrl;
  final String? role; // 'customer' or 'driver'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.photoUrl,
    this.role,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? photoUrl,
    String? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
    );
  }
}
