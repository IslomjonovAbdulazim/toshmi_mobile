import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String phone;
  final String role;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'is_active')
  final bool isActive;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'profile_image_id')
  final int? profileImageId;

  const UserModel({
    required this.id,
    required this.phone,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    this.profileImageId,
  });

  // Computed property for full name
  String get fullName => '$firstName $lastName';

  // Check user role
  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isStudent => role == 'student';
  bool get isParent => role == 'parent';

  // Get display name based on role
  String get displayName {
    switch (role) {
      case 'admin':
        return 'Administrator: $fullName';
      case 'teacher':
        return 'Ustoz: $fullName';
      case 'student':
        return 'Talaba: $fullName';
      case 'parent':
        return 'Ota-ona: $fullName';
      default:
        return fullName;
    }
  }

  // Get role in Uzbek
  String get roleUz {
    switch (role) {
      case 'admin':
        return 'Administrator';
      case 'teacher':
        return 'Ustoz';
      case 'student':
        return 'Talaba';
      case 'parent':
        return 'Ota-ona';
      default:
        return role;
    }
  }

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Copy with method
  UserModel copyWith({
    int? id,
    String? phone,
    String? role,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAt,
    int? profileImageId,
  }) {
    return UserModel(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      profileImageId: profileImageId ?? this.profileImageId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'UserModel(id: $id, phone: $phone, role: $role, fullName: $fullName, isActive: $isActive)';
  }
}