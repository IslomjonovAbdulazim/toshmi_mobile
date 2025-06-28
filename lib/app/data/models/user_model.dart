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
    // Handle different API response formats
    String firstName = '';
    String lastName = '';

    if (json.containsKey('name')) {
      // Login response format: {id, name, phone}
      final nameParts = (json['name'] as String).split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    } else {
      // Profile response format: {first_name, last_name}
      firstName = json['first_name'] ?? '';
      lastName = json['last_name'] ?? '';
    }

    return User(
      id: json['id'],
      phone: json['phone'],
      passwordHash: json['password_hash'] ?? '',
      role: json['role'] ?? '',
      firstName: firstName,
      lastName: lastName,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
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