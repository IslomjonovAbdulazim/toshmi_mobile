import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'auth_models.g.dart';

// Login request model
@JsonSerializable()
class LoginRequest {
  final String phone;
  final String password;
  final String role;

  const LoginRequest({
    required this.phone,
    required this.password,
    required this.role,
  });

  // JSON serialization
  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() {
    return 'LoginRequest(phone: $phone, role: $role)';
  }
}

// Login response model
@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;
  @JsonKey(name: 'token_type')
  final String tokenType;
  final String role;
  final UserInfo user;

  const LoginResponse({
    required this.accessToken,
    required this.tokenType,
    required this.role,
    required this.user,
  });

  // Get full authorization header
  String get authorizationHeader => '$tokenType $accessToken';

  // JSON serialization
  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  String toString() {
    return 'LoginResponse(role: $role, user: ${user.name})';
  }
}

// User info model (nested in login response)
@JsonSerializable()
class UserInfo {
  final int id;
  final String name;
  final String phone;

  const UserInfo({
    required this.id,
    required this.name,
    required this.phone,
  });

  // JSON serialization
  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  @override
  String toString() {
    return 'UserInfo(id: $id, name: $name, phone: $phone)';
  }
}

// Change password request model
@JsonSerializable()
class ChangePasswordRequest {
  @JsonKey(name: 'old_password')
  final String oldPassword;
  @JsonKey(name: 'new_password')
  final String newPassword;

  const ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
  });

  // JSON serialization
  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);

  @override
  String toString() {
    return 'ChangePasswordRequest(oldPassword: ***, newPassword: ***)';
  }
}

// Update profile request model
@JsonSerializable()
class UpdateProfileRequest {
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;

  const UpdateProfileRequest({
    required this.firstName,
    required this.lastName,
  });

  // JSON serialization
  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);

  @override
  String toString() {
    return 'UpdateProfileRequest(firstName: $firstName, lastName: $lastName)';
  }
}

// Profile response model
@JsonSerializable()
class ProfileResponse {
  final int id;
  final String phone;
  final String role;
  @JsonKey(name: 'first_name')
  final String firstName;
  @JsonKey(name: 'last_name')
  final String lastName;
  @JsonKey(name: 'full_name')
  final String fullName;
  @JsonKey(name: 'profile_image_id')
  final int? profileImageId;

  const ProfileResponse({
    required this.id,
    required this.phone,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.profileImageId,
  });

  // Convert to UserModel
  UserModel toUserModel() {
    return UserModel(
      id: id,
      phone: phone,
      role: role,
      firstName: firstName,
      lastName: lastName,
      isActive: true, // Assume active if profile is accessible
      createdAt: DateTime.now(), // Will be updated when full user data is loaded
      profileImageId: profileImageId,
    );
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
  factory ProfileResponse.fromJson(Map<String, dynamic> json) => _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  @override
  String toString() {
    return 'ProfileResponse(id: $id, fullName: $fullName, role: $roleUz)';
  }
}

// Generic API response model
@JsonSerializable()
class ApiResponse {
  final String message;

  const ApiResponse({
    required this.message,
  });

  // JSON serialization
  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  @override
  String toString() {
    return 'ApiResponse(message: $message)';
  }
}

// Create response model (for POST endpoints)
@JsonSerializable()
class CreateResponse {
  final String message;
  final int id;

  const CreateResponse({
    required this.message,
    required this.id,
  });

  // JSON serialization
  factory CreateResponse.fromJson(Map<String, dynamic> json) => _$CreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateResponseToJson(this);

  @override
  String toString() {
    return 'CreateResponse(message: $message, id: $id)';
  }
}