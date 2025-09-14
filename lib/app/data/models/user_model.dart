// lib/app/data/models/user_model.dart
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
  final String? avatarUrl;

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
    this.avatarUrl,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) {
    print('🔄 Parsing user from JSON: $json');

    // Handle different API response formats
    String firstName = '';
    String lastName = '';

    if (json.containsKey('name')) {
      // Login response format: {id, name, phone, role}
      final nameParts = (json['name'] as String).trim().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : '';
      lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      print('👤 Parsed name: $firstName $lastName');
    } else {
      // Profile response format: {first_name, last_name}
      firstName = json['first_name']?.toString().trim() ?? '';
      lastName = json['last_name']?.toString().trim() ?? '';
    }

    // Validate required fields
    final id = json['id'];
    if (id == null || id == 0) {
      throw Exception('Invalid user ID: $id');
    }

    final phone = json['phone']?.toString().trim() ?? '';
    if (phone.isEmpty) {
      throw Exception('Phone number is required');
    }

    final role = json['role']?.toString().trim().toLowerCase() ?? '';
    if (role.isEmpty) {
      throw Exception('User role is required');
    }

    print('✅ User validation passed - ID: $id, Role: $role');

    return User(
      id: id,
      phone: phone,
      passwordHash: json['password_hash']?.toString() ?? '',
      role: role,
      firstName: firstName,
      lastName: lastName,
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      profileImageId: json['profile_image_id'],
      avatarUrl: json['avatar_url'],
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
      'avatar_url': avatarUrl,
      // Also include 'name' field for compatibility
      'name': fullName,
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
    String? avatarUrl,
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
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, phone: $phone, role: $role, active: $isActive)';
  }
}