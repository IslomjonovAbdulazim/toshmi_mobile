import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

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

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);

  @override
  String toString() => 'LoginRequest(phone: $phone, role: $role)';
}

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

  String get authorizationHeader => '$tokenType $accessToken';

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

  @override
  String toString() => 'LoginResponse(role: $role, user: ${user.name})';
}

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

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);
  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  @override
  String toString() => 'UserInfo(id: $id, name: $name)';
}

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

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

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

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) => _$UpdateProfileRequestFromJson(json);
  Map<String, dynamic> toJson() => _$UpdateProfileRequestToJson(this);
}

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

  String get roleUz => switch (role) {
    'admin' => 'Administrator',
    'teacher' => 'Ustoz',
    'student' => 'Talaba',
    'parent' => 'Ota-ona',
    _ => role,
  };

  factory ProfileResponse.fromJson(Map<String, dynamic> json) => _$ProfileResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileResponseToJson(this);

  @override
  String toString() => 'ProfileResponse(id: $id, fullName: $fullName, role: $roleUz)';
}

@JsonSerializable()
class ApiResponse {
  final String message;

  const ApiResponse({required this.message});

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);

  @override
  String toString() => 'ApiResponse(message: $message)';
}

@JsonSerializable()
class CreateResponse {
  final String message;
  final int id;

  const CreateResponse({
    required this.message,
    required this.id,
  });

  factory CreateResponse.fromJson(Map<String, dynamic> json) => _$CreateResponseFromJson(json);
  Map<String, dynamic> toJson() => _$CreateResponseToJson(this);

  @override
  String toString() => 'CreateResponse(message: $message, id: $id)';
}