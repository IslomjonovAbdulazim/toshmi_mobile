import 'package:get/get.dart';
import '../../core/constants/api_constants.dart';
import '../models/auth_models.dart';
import '../models/notification_model.dart';
import '../models/api_response_models.dart';
import '../services/auth_service.dart';

// Repository interface
abstract class IAuthRepository {
  // Authentication
  Future<AuthResult<User>> login({
    required String phone,
    required String password,
    required String role,
  });
  Future<void> logout();
  Future<bool> checkAuthenticationStatus();

  // Profile management
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

  // Auth state
  bool get isAuthenticated;
  String? get userRole;
  User? get currentUser;
  int get cachedUnreadCount;

  // Role getters
  bool get isAdmin;
  bool get isTeacher;
  bool get isStudent;
  bool get isParent;

  // Display getters
  String get userDisplayName;
  String get userDisplayPhone;

  // Validation
  bool isValidPhone(String phone);
  PasswordValidation validatePassword(String password);
  String formatPhoneForDisplay(String phone);

  // Refresh
  Future<void> refreshUserData();
}

// Repository implementation
class AuthRepository extends GetxService implements IAuthRepository {
  static AuthRepository get to => Get.find();

  final AuthService _authService = Get.find<AuthService>();

  // Authentication
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

  // Profile management
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
      final result = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
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
      final validation = validatePassword(newPassword);
      if (!validation.isValid) {
        return AuthResult.failure(
          AuthFailure.invalidInput(validation.errorMessage),
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

  // Notifications
  @override
  Future<AuthResult<List<NotificationModel>>> getNotifications({
    int skip = 0,
    int limit = 20,
  }) async {
    try {
      final result = await _authService.getNotifications(skip: skip, limit: limit);

      if (result.isSuccess && result.data != null) {
        return AuthResult.success(result.data!);
      } else {
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
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
        return AuthResult.failure(
          _mapApiErrorToAuthFailure(result.error),
        );
      }
    } catch (e) {
      return AuthResult.failure(
        AuthFailure.unknown('Failed to get unread count: ${e.toString()}'),
      );
    }
  }

  // Auth state getters
  @override
  bool get isAuthenticated => _authService.isAuthenticated;

  @override
  String? get userRole => _authService.userRole;

  @override
  User? get currentUser {
    final userData = _authService.currentUser;
    if (userData != null) {
      return User(
        id: userData['id'] as int,
        name: userData['name'] as String,
        phone: userData['phone'] as String,
        role: userRole ?? '',
      );
    }
    return null;
  }

  @override
  int get cachedUnreadCount => 0; // Could be implemented with cache

  // Role checks
  bool _hasRole(String role) => userRole == role;

  @override
  bool get isAdmin => _hasRole(UserRoles.admin);

  @override
  bool get isTeacher => _hasRole(UserRoles.teacher);

  @override
  bool get isStudent => _hasRole(UserRoles.student);

  @override
  bool get isParent => _hasRole(UserRoles.parent);

  // Display getters
  @override
  String get userDisplayName {
    final user = currentUser;
    return user?.name ?? 'Unknown User';
  }

  @override
  String get userDisplayPhone {
    final user = currentUser;
    if (user != null) {
      return formatPhoneForDisplay(user.phone);
    }
    return '';
  }

  // Validation methods
  @override
  bool isValidPhone(String phone) {
    // Remove spaces and check if it matches +998XXXXXXXXX format
    final cleanPhone = phone.replaceAll(' ', '');
    return RegExp(r'^\+998[0-9]{9}$').hasMatch(cleanPhone);
  }

  @override
  PasswordValidation validatePassword(String password) {
    final hasMinLength = password.length >= 6;
    final hasLetters = RegExp(r'[a-zA-Z]').hasMatch(password);
    final hasNumbers = RegExp(r'[0-9]').hasMatch(password);

    String errorMessage = '';
    bool isValid = hasMinLength && hasLetters;

    if (!hasMinLength) {
      errorMessage = 'Parol kamida 6 ta belgidan iborat bo\'lishi kerak';
    } else if (!hasLetters) {
      errorMessage = 'Parolda kamida bitta harf bo\'lishi kerak';
    }

    return PasswordValidation(
      isValid: isValid,
      hasMinLength: hasMinLength,
      hasLetters: hasLetters,
      hasNumbers: hasNumbers,
      errorMessage: errorMessage,
    );
  }

  @override
  String formatPhoneForDisplay(String phone) {
    final cleanPhone = phone.replaceAll(' ', '');
    if (cleanPhone.startsWith('+998') && cleanPhone.length == 13) {
      return '+998 ${cleanPhone.substring(4, 6)} ${cleanPhone.substring(6, 9)} ${cleanPhone.substring(9, 11)} ${cleanPhone.substring(11)}';
    }
    return phone;
  }

  @override
  Future<void> refreshUserData() async {
    await _authService.refreshUserData();
  }

  // Helper method to map API errors to auth failures
  AuthFailure _mapApiErrorToAuthFailure(ApiError? error) {
    if (error == null) {
      return AuthFailure.unknown('Unknown error occurred');
    }

    switch (error.type) {
      case 'validation_error':
        return AuthFailure.invalidInput(error.detail);
      case 'auth_error':
        return AuthFailure.invalidCredentials(error.detail);
      case 'network_error':
        return AuthFailure.networkError(error.detail);
      case 'server_error':
        return AuthFailure.serverError(error.detail);
      default:
        return AuthFailure.unknown(error.detail);
    }
  }
}

// Domain models
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
          other is User && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// Password validation result
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

// Authentication result wrapper
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

  T get dataOrThrow {
    if (isSuccess && data != null) {
      return data!;
    }
    throw failure ?? AuthFailure.unknown('Unknown error');
  }

  T getDataOrElse(T defaultValue) {
    return isSuccess && data != null ? data! : defaultValue;
  }
}

// Authentication failure types
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

enum AuthFailureType {
  invalidCredentials,
  invalidInput,
  networkError,
  serverError,
  unknown,
}

// User roles constants
abstract class UserRoles {
  static const String admin = 'admin';
  static const String teacher = 'teacher';
  static const String student = 'student';
  static const String parent = 'parent';

  static const List<String> all = [admin, teacher, student, parent];

  static String getDisplayName(String role) => switch (role) {
    admin => 'Administrator',
    teacher => 'Ustoz',
    student => 'Talaba',
    parent => 'Ota-ona',
    _ => 'Unknown',
  };
}