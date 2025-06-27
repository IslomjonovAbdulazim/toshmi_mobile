class User {
  final int id;
  final String phone;
  final String passwordHash;
  final String role;
  final String firstName;
  final String lastName;
  final bool isActive;
  final DateTime createdAt;
  final int? profileImageId;

  User({
    required this.id,
    required this.phone,
    required this.passwordHash,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    this.profileImageId,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phone: json['phone'],
      passwordHash: json['password_hash'] ?? '',
      role: json['role'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      profileImageId: json['profile_image_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'password_hash': passwordHash,
      'role': role,
      'first_name': firstName,
      'last_name': lastName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'profile_image_id': profileImageId,
    };
  }

  User copyWith({
    int? id,
    String? phone,
    String? passwordHash,
    String? role,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAt,
    int? profileImageId,
  }) {
    return User(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      passwordHash: passwordHash ?? this.passwordHash,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      profileImageId: profileImageId ?? this.profileImageId,
    );
  }
}