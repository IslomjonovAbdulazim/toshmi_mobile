class ValidationHelper {
  // Required field validation
  static String? required(String? value, {String fieldName = 'Maydon'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName kiritilishi shart';
    }
    return null;
  }

  // Email validation
  static String? email(String? value) {
    if (value == null || value.isEmpty) return null;

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Noto\'g\'ri email formati';
    }
    return null;
  }

  // Phone validation (Uzbek format)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;

    final phoneRegex = RegExp(r'^\+998[0-9]{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefon raqami +998901234567 formatida bo\'lishi kerak';
    }
    return null;
  }

  // Password validation
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return 'Parol kamida $minLength ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  // Confirm password validation
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) return null;

    if (value != originalPassword) {
      return 'Parollar mos kelmayapti';
    }
    return null;
  }

  // Number validation
  static String? number(String? value, {String fieldName = 'Raqam'}) {
    if (value == null || value.isEmpty) return null;

    if (int.tryParse(value) == null) {
      return '$fieldName faqat raqamlardan iborat bo\'lishi kerak';
    }
    return null;
  }

  // Grade validation (0-100)
  static String? grade(String? value) {
    if (value == null || value.isEmpty) return null;

    final grade = int.tryParse(value);
    if (grade == null) {
      return 'Ball faqat raqamlardan iborat bo\'lishi kerak';
    }

    if (grade < 0 || grade > 100) {
      return 'Ball 0 dan 100 gacha bo\'lishi kerak';
    }
    return null;
  }

  // Min length validation
  static String? minLength(String? value, int minLength, {String fieldName = 'Maydon'}) {
    if (value == null || value.isEmpty) return null;

    if (value.length < minLength) {
      return '$fieldName kamida $minLength ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  // Max length validation
  static String? maxLength(String? value, int maxLength, {String fieldName = 'Maydon'}) {
    if (value == null || value.isEmpty) return null;

    if (value.length > maxLength) {
      return '$fieldName ko\'pi bilan $maxLength ta belgidan iborat bo\'lishi kerak';
    }
    return null;
  }

  // Age validation
  static String? age(String? value, {int minAge = 0, int maxAge = 120}) {
    if (value == null || value.isEmpty) return null;

    final age = int.tryParse(value);
    if (age == null) {
      return 'Yosh faqat raqamlardan iborat bo\'lishi kerak';
    }

    if (age < minAge || age > maxAge) {
      return 'Yosh $minAge dan $maxAge gacha bo\'lishi kerak';
    }
    return null;
  }

  // Year validation
  static String? graduationYear(String? value) {
    if (value == null || value.isEmpty) return null;

    final year = int.tryParse(value);
    if (year == null) {
      return 'Yil faqat raqamlardan iborat bo\'lishi kerak';
    }

    final currentYear = DateTime.now().year;
    if (year < currentYear || year > currentYear + 10) {
      return 'Bitirish yili $currentYear dan ${currentYear + 10} gacha bo\'lishi kerak';
    }
    return null;
  }

  // Amount validation
  static String? amount(String? value, {int minAmount = 0}) {
    if (value == null || value.isEmpty) return null;

    final amount = int.tryParse(value);
    if (amount == null) {
      return 'Miqdor faqat raqamlardan iborat bo\'lishi kerak';
    }

    if (amount < minAmount) {
      return 'Miqdor $minAmount dan kam bo\'lmasligi kerak';
    }
    return null;
  }
}