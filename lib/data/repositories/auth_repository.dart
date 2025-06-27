import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import '../services/auth_service.dart';

/// Repository interface for authentication operations
abstract class IAuthRepository {
  // Authentication
  Future<AuthResult<User>> login({
    required String phone,
    required String password,
    required String role,
  });
  Future<void> logout();
  Future<bool> checkAuthenticationStatus();

  // Profile Management
  Future<AuthResult<ProfileResponse>> getProfile();
  Future<AuthResult<void>> updateProfile({
    required String firstName,
    required String lastName,
  });
  Future<AuthResult<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  // Notifications
  Future<AuthResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
  });
  Future<AuthResult<void>> markNotificationRead(int notificationId);
  Future<AuthResult<void>> markAllNotificationsRead();
  Future<AuthResult<int>> getUnreadNotificationCount();

  // Auth State
  bool get isAuthenticated;
  String? get userRole;
  User? get currentUser;
  int get cachedUnreadCount;

  // Validation
  bool isValidPhone(String phone);
  PasswordValidation validatePassword(String password);
  String formatPhoneForDisplay(String phone);
}

/// Authentication repository implementation
class AuthRepository extends GetxService implements IAuthRepository {
  static AuthRepository get to => Get.find();

  final AuthService _authService = Get.find<AuthService>();

  // ===================== AUTHENTICATION =====================

  @override
  Future<AuthResult<User>> login({
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      // Validate input
      if (!isValidPhone(phone)) {
        return AuthResult.failure(
          AuthFailure.invalidInput('Invalid phone number format'),
        );
      }

      if (password.isEmpty || password.length < 6) {
        return AuthResult.failure(
          AuthFailure.invalidInput('Password must be at least 6 characters'),
        );
      }

      // Attempt login
      final result = await _authService.login(
        phone: phone,
        password: password,
        role: role,
      );

      if (result.isSuccess && result.data != null) {
        final user = User.fromLoginResponse(result.data!);
        return AuthResult.success(user);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Login failed: ${e.toString()}'),
      );
    }
  }

  @override
  Future<void> logout() async {
    await _authService.logout();
  }

  @override
  Future<bool> checkAuthenticationStatus() async {
    return await _authService.checkAuthenticationStatus();
  }

  // ===================== PROFILE MANAGEMENT =====================

  @override
  Future<AuthResult<ProfileResponse>> getProfile() async {
    try {
      final result = await _authService.getProfile();

      if (result.isSuccess && result.data != null) {
        return AuthResult.success(result.data!);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to get profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult<void>> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Validate input
      if (firstName.trim().isEmpty || lastName.trim().isEmpty) {
        return AuthResult.failure(
          AuthFailure.invalidInput('First name and last name are required'),
        );
      }

      final result = await _authService.updateProfile(
        firstName: firstName.trim(),
        lastName: lastName.trim(),
      );

      if (result.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to update profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult<void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      // Validate passwords
      if (oldPassword.isEmpty) {
        return AuthResult.failure(
          AuthFailure.invalidInput('Current password is required'),
        );
      }

      final passwordValidation = validatePassword(newPassword);
      if (!passwordValidation.isValid) {
        return AuthResult.failure(
          AuthFailure.invalidInput(passwordValidation.errorMessage),
        );
      }

      final result = await _authService.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );

      if (result.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to change password: ${e.toString()}'),
      );
    }
  }

  // ===================== NOTIFICATIONS =====================

  @override
  Future<AuthResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final result = await _authService.getNotifications(
        skip: skip,
        limit: limit,
      );

      if (result.isSuccess && result.data != null) {
        return AuthResult.success(result.data!);
      } else {
        // Return cached notifications if available
        if (skip == 0) {
          final cachedNotifications = _authService.getCachedNotifications();
          if (cachedNotifications.isNotEmpty) {
            return AuthResult.success(cachedNotifications);
          }
        }

        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      // Return cached notifications on error
      if (skip == 0) {
        final cachedNotifications = _authService.getCachedNotifications();
        if (cachedNotifications.isNotEmpty) {
          return AuthResult.success(cachedNotifications);
        }
      }

      return AuthResult.failure(
        AuthFailure.unknown('Failed to get notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult<void>> markNotificationRead(int notificationId) async {
    try {
      final result = await _authService.markNotificationRead(notificationId);

      if (result.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to mark notification as read: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult<void>> markAllNotificationsRead() async {
    try {
      final result = await _authService.markAllNotificationsRead();

      if (result.isSuccess) {
        return AuthResult.success(null);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to mark all notifications as read: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AuthResult<int>> getUnreadNotificationCount() async {
    try {
      final result = await _authService.getUnreadNotificationCount();

      if (result.isSuccess && result.data != null) {
        return AuthResult.success(result.data!.unreadCount);
      } else {
        // Return cached count if available
        final cachedCount = _authService.getCachedUnreadCount();
        return AuthResult.success(cachedCount);
      }
    } catch (e) {
      // Return cached count on error
      final cachedCount = _authService.getCachedUnreadCount();
      return AuthResult.success(cachedCount);
    }
  }

  // ===================== AUTH STATE =====================

  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  String? get userRole => _authService.userRole;

  @override
  User? get currentUser {
    final profile = _authService.userProfile;
    if (profile != null && userRole != null) {
      return User(
        id: profile['id'] as int,
        name: profile['name'] as String,
        phone: profile['phone'] as String,
        role: userRole!,
      );
    }
    return null;
  }

  @override
  int get cachedUnreadCount => _authService.getCachedUnreadCount();

  // ===================== VALIDATION =====================

  @override
  bool isValidPhone(String phone) => _authService.isValidPhone(phone);

  @override
  PasswordValidation validatePassword(String password) {
    final validation = _authService.validatePassword(password);

    return PasswordValidation(
      isValid: validation['isStrong'] == true,
      hasMinLength: validation['minLength'] == true,
      hasLetters: validation['hasLetters'] == true,
      hasNumbers: validation['hasNumbers'] == true,
      errorMessage: _getPasswordErrorMessage(validation),
    );
  }

  @override
  String formatPhoneForDisplay(String phone) =>
      _authService.formatPhoneForDisplay(phone);

  // ===================== HELPER METHODS =====================

  /// Map API error to auth failure
  AuthFailure _mapApiErrorToAuthFailure(ApiError? error) {
    if (error == null) {
      return AuthFailure.unknown('Unknown error occurred');
    }

    switch (error.type) {
      case 'validation_error':
        return AuthFailure.invalidInput(error.detail);
      case 'authentication_error':
        return AuthFailure.invalidCredentials(error.detail);
      case 'network_error':
        return AuthFailure.networkError(error.detail);
      case 'server_error':
        return AuthFailure.serverError(error.detail);
      default:
        return AuthFailure.unknown(error.detail);
    }
  }

  /// Get password error message
  String _getPasswordErrorMessage(Map<String, bool> validation) {
    if (validation['minLength'] != true) {
      return 'Password must be at least 6 characters long';
    }
    if (validation['hasLetters'] != true) {
      return 'Password must contain letters';
    }
    if (validation['hasNumbers'] != true) {
      return 'Password must contain numbers';
    }
    return '';
  }

  // ===================== ROLE HELPERS =====================

  /// Check if current user has specific role
  bool hasRole(String role) => userRole == role;

  /// Check if current user is admin
  bool get isAdmin => hasRole(UserRoles.admin);

  /// Check if current user is teacher
  bool get isTeacher => hasRole(UserRoles.teacher);

  /// Check if current user is student
  bool get isStudent => hasRole(UserRoles.student);

  /// Check if current user is parent
  bool get isParent => hasRole(UserRoles.parent);

  // ===================== BUSINESS LOGIC =====================

  /// Get user display name
  String get userDisplayName {
    final user = currentUser;
    if (user != null) {
      return user.name;
    }
    return 'Unknown User';
  }

  /// Get user display phone
  String get userDisplayPhone {
    final user = currentUser;
    if (user != null) {
      return formatPhoneForDisplay(user.phone);
    }
    return '';
  }

  /// Refresh all user data
  Future<void> refreshUserData() async {
    await _authService.refreshUserData();
  }
}

// ===================== DOMAIN MODELS =====================

/// User domain model
class User {
  final int id;
  final String name;
  final String phone;
  final String role;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
  });

  factory User.fromLoginResponse(LoginResponse response) {
    return User(
      id: response.user.id,
      name: response.user.name,
      phone: response.user.phone,
      role: response.role,
    );
  }

  @override
  String toString() => 'User(id: $id, name: $name, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is User &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Password validation result
class PasswordValidation {
  final bool isValid;
  final bool hasMinLength;
  final bool hasLetters;
  final bool hasNumbers;
  final String errorMessage;

  const PasswordValidation({
    required this.isValid,
    required this.hasMinLength,
    required this.hasLetters,
    required this.hasNumbers,
    required this.errorMessage,
  });
}

/// Authentication result wrapper
class AuthResult<T> {
  final T? data;
  final AuthFailure? failure;
  final bool isSuccess;

  const AuthResult._({
    this.data,
    this.failure,
    required this.isSuccess,
  });

  factory AuthResult.success(T data) {
    return AuthResult._(data: data, isSuccess: true);
  }

  factory AuthResult.failure(AuthFailure failure) {
    return AuthResult._(failure: failure, isSuccess: false);
  }

  /// Get data or throw if failure
  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw failure ?? AuthFailure.unknown('Unknown error');
  }

  /// Get data or return default value
  T getDataOrElse(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }
}

/// Authentication failure types
class AuthFailure {
  final String message;
  final AuthFailureType type;

  const AuthFailure._(this.message, this.type);

  factory AuthFailure.invalidCredentials(String message) =>
      AuthFailure._(message, AuthFailureType.invalidCredentials);

  factory AuthFailure.invalidInput(String message) =>
      AuthFailure._(message, AuthFailureType.invalidInput);

  factory AuthFailure.networkError(String message) =>
      AuthFailure._(message, AuthFailureType.networkError);

  factory AuthFailure.serverError(String message) =>
      AuthFailure._(message, AuthFailureType.serverError);

  factory AuthFailure.unknown(String message) =>
      AuthFailure._(message, AuthFailureType.unknown);

  @override
  String toString() => 'AuthFailure: $message (${type.name})';
}

/// Authentication failure types enumeration
enum AuthFailureType {
  invalidCredentials,
  invalidInput,
  networkError,
  serverError,
  unknown,
}

// ===================== USER ROLES CONSTANTS =====================

/// User roles constants
abstract class UserRoles {
  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String student = 'student';
  static const String parent = 'parent';

  static const List<String> all = [admin, teacher, student, parent];

  static String getDisplayName(String role) {
    switch (role) {
      case admin:
        return 'Administrator';
      case teacher:
        return 'Teacher';
      case student:
        return 'Student';
      case parent:
        return 'Parent';
      default:
        return 'Unknown';
    }
  }
}