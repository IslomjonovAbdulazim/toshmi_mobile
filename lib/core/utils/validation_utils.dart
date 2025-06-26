import 'dart:io';
import '../constants/app_constants.dart';

class ValidationUtils {
  /// Validate email
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (!AppConstants.isValidEmail(value.trim())) {
      return 'To\'g\'ri email manzilini kiriting';
    }

    return null;
  }

  /// Validate phone
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    // Clean phone number (remove spaces, dashes, etc.)
    final cleanedPhone = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    if (!AppConstants.isValidPhone(cleanedPhone)) {
      return 'To\'g\'ri telefon raqamini kiriting';
    }

    return null;
  }

  /// Validate password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (value.length < AppConstants.minPasswordLength) {
      return 'Parol kamida ${AppConstants.minPasswordLength} ta belgidan iborat bo\'lishi kerak';
    }

    if (value.length > AppConstants.maxPasswordLength) {
      return 'Parol ko\'pi bilan ${AppConstants.maxPasswordLength} ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate confirm password
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (value != password) {
      return 'Parollar mos kelmaydi';
    }

    return null;
  }

  /// Validate required field
  static String? validateRequired(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      if (fieldName != null) {
        return '$fieldName to\'ldirilishi shart';
      }
      return 'Bu maydon to\'ldirilishi shart';
    }
    return null;
  }

  /// Validate min length
  static String? validateMinLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (value.length < minLength) {
      return 'Kamida $minLength ta belgi bo\'lishi kerak';
    }

    return null;
  }

  /// Validate max length
  static String? validateMaxLength(String? value, int maxLength) {
    if (value != null && value.length > maxLength) {
      return 'Ko\'pi bilan $maxLength ta belgi bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate length range
  static String? validateLengthRange(String? value, int minLength, int maxLength) {
    if (value == null || value.isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (value.length < minLength) {
      return 'Kamida $minLength ta belgi bo\'lishi kerak';
    }

    if (value.length > maxLength) {
      return 'Ko\'pi bilan $maxLength ta belgi bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate number
  static String? validateNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Faqat raqam kiriting';
    }

    return null;
  }

  /// Validate integer
  static String? validateInteger(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Faqat butun son kiriting';
    }

    return null;
  }

  /// Validate positive number
  static String? validatePositiveNumber(String? value) {
    final numberValidation = validateNumber(value);
    if (numberValidation != null) return numberValidation;

    final number = double.parse(value!.trim());
    if (number <= 0) {
      return 'Musbat raqam kiriting';
    }

    return null;
  }

  /// Validate positive integer
  static String? validatePositiveInteger(String? value) {
    final integerValidation = validateInteger(value);
    if (integerValidation != null) return integerValidation;

    final number = int.parse(value!.trim());
    if (number <= 0) {
      return 'Musbat butun son kiriting';
    }

    return null;
  }

  /// Validate number range
  static String? validateNumberRange(String? value, double min, double max) {
    final numberValidation = validateNumber(value);
    if (numberValidation != null) return numberValidation;

    final number = double.parse(value!.trim());
    if (number < min || number > max) {
      return 'Qiymat $min dan $max gacha bo\'lishi kerak';
    }

    return null;
  }

  /// Validate username
  static String? validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < AppConstants.minUsernameLength) {
      return 'Foydalanuvchi nomi kamida ${AppConstants.minUsernameLength} ta belgidan iborat bo\'lishi kerak';
    }

    if (trimmedValue.length > AppConstants.maxUsernameLength) {
      return 'Foydalanuvchi nomi ko\'pi bilan ${AppConstants.maxUsernameLength} ta belgidan iborat bo\'lishi mumkin';
    }

    if (!AppConstants.isValidUsername(trimmedValue)) {
      return 'Foydalanuvchi nomi faqat harf, raqam va _ dan iborat bo\'lishi kerak';
    }

    return null;
  }

  /// Validate full name
  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < AppConstants.minNameLength) {
      return 'Ism kamida ${AppConstants.minNameLength} ta belgidan iborat bo\'lishi kerak';
    }

    if (trimmedValue.length > AppConstants.maxNameLength) {
      return 'Ism ko\'pi bilan ${AppConstants.maxNameLength} ta belgidan iborat bo\'lishi mumkin';
    }

    // Check if contains at least one letter
    if (!RegExp(r'[a-zA-ZА-Яа-яЁёўғқҳ]').hasMatch(trimmedValue)) {
      return 'Ism kamida bitta harf bo\'lishi kerak';
    }

    return null;
  }

  /// Validate date string
  static String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    try {
      DateTime.parse(value.trim());
      return null;
    } catch (e) {
      return 'To\'g\'ri sana formatini kiriting';
    }
  }

  /// Validate date range
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) {
      return 'Sanalarni tanlang';
    }

    if (startDate.isAfter(endDate)) {
      return 'Boshlanish sanasi tugash sanasidan kech bo\'lishi mumkin emas';
    }

    return null;
  }

  /// Validate URL
  static String? validateUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu maydon to\'ldirilishi shart';
    }

    final trimmedValue = value.trim();

    try {
      final uri = Uri.parse(trimmedValue.startsWith('http') ? trimmedValue : 'https://$trimmedValue');
      if (!uri.hasScheme || uri.host.isEmpty) {
        return 'To\'g\'ri URL kiriting';
      }
      return null;
    } catch (e) {
      return 'To\'g\'ri URL kiriting';
    }
  }

  /// Validate file size
  static String? validateFileSize(File file, int maxSize) {
    try {
      final size = file.lengthSync();
      if (size > maxSize) {
        final maxSizeMB = (maxSize / (1024 * 1024)).toStringAsFixed(1);
        return 'Fayl hajmi ${maxSizeMB}MB dan oshmasligi kerak';
      }
      return null;
    } catch (e) {
      print('ValidationUtils: Error checking file size: $e');
      return 'Fayl hajmini tekshirishda xatolik';
    }
  }

  /// Validate file type
  static String? validateFileType(String filePath, List<String> allowedTypes) {
    final extension = filePath.split('.').last.toLowerCase();
    if (!allowedTypes.contains(extension)) {
      return 'Ruxsat etilgan formatlar: ${allowedTypes.join(', ')}';
    }
    return null;
  }

  /// Validate homework title
  static String? validateHomeworkTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vazifa nomi kiritilishi shart';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Vazifa nomi kamida 3 ta belgidan iborat bo\'lishi kerak';
    }

    if (trimmedValue.length > 100) {
      return 'Vazifa nomi ko\'pi bilan 100 ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate homework description
  static String? validateHomeworkDescription(String? value) {
    if (value != null && value.length > AppConstants.maxHomeworkDescriptionLength) {
      return 'Tavsif ko\'pi bilan ${AppConstants.maxHomeworkDescriptionLength} ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate exam title
  static String? validateExamTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Imtihon nomi kiritilishi shart';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return 'Imtihon nomi kamida 3 ta belgidan iborat bo\'lishi kerak';
    }

    if (trimmedValue.length > 100) {
      return 'Imtihon nomi ko\'pi bilan 100 ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate grade points
  static String? validateGradePoints(String? value, int maxPoints) {
    final numberValidation = validateInteger(value);
    if (numberValidation != null) return numberValidation;

    final points = int.parse(value!.trim());
    if (points < 0) {
      return 'Ball manfiy bo\'lishi mumkin emas';
    }

    if (points > maxPoints) {
      return 'Ball $maxPoints dan oshmasligi kerak';
    }

    return null;
  }

  /// Validate comment
  static String? validateComment(String? value) {
    if (value != null && value.length > AppConstants.maxCommentLength) {
      return 'Izoh ko\'pi bilan ${AppConstants.maxCommentLength} ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate payment amount
  static String? validatePaymentAmount(String? value) {
    final numberValidation = validatePositiveNumber(value);
    if (numberValidation != null) return numberValidation;

    final amount = double.parse(value!.trim());
    if (amount > 100000000) { // 100 million som limit
      return 'To\'lov miqdori juda katta';
    }

    return null;
  }

  /// Validate search query
  static String? validateSearchQuery(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Qidiruv so\'zini kiriting';
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return 'Qidiruv so\'zi kamida 2 ta belgidan iborat bo\'lishi kerak';
    }

    if (trimmedValue.length > 100) {
      return 'Qidiruv so\'zi ko\'pi bilan 100 ta belgidan iborat bo\'lishi mumkin';
    }

    return null;
  }

  /// Validate multiple fields at once
  static Map<String, String> validateMultipleFields(Map<String, dynamic> fields) {
    final errors = <String, String>{};

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldData = entry.value;

      if (fieldData is Map<String, dynamic>) {
        final value = fieldData['value'] as String?;
        final validatorType = fieldData['type'] as String?;
        final params = fieldData['params'] as Map<String, dynamic>?;

        String? error;

        switch (validatorType) {
          case 'required':
            error = validateRequired(value, fieldName: fieldName);
            break;
          case 'email':
            error = validateEmail(value);
            break;
          case 'phone':
            error = validatePhone(value);
            break;
          case 'password':
            error = validatePassword(value);
            break;
          case 'number':
            error = validateNumber(value);
            break;
          case 'positiveNumber':
            error = validatePositiveNumber(value);
            break;
          case 'minLength':
            error = validateMinLength(value, params?['minLength'] ?? 1);
            break;
          case 'maxLength':
            error = validateMaxLength(value, params?['maxLength'] ?? 100);
            break;
          case 'lengthRange':
            error = validateLengthRange(
                value,
                params?['minLength'] ?? 1,
                params?['maxLength'] ?? 100
            );
            break;
          default:
            error = validateRequired(value);
        }

        if (error != null) {
          errors[fieldName] = error;
        }
      }
    }

    return errors;
  }

  /// Check if validation errors exist
  static bool hasValidationErrors(Map<String, String> errors) {
    return errors.isNotEmpty;
  }

  /// Get first validation error
  static String? getFirstValidationError(Map<String, String> errors) {
    return errors.values.isNotEmpty ? errors.values.first : null;
  }

  /// Clean input value (trim and remove extra spaces)
  static String? cleanInput(String? value) {
    if (value == null) return null;
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Format validation error message
  static String formatValidationError(String fieldName, String error) {
    return '$fieldName: $error';
  }
}