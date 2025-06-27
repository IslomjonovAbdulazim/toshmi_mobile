extension StringExtensions on String {
  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  // Title case
  String get titleCase {
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  // Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  // Check if string is valid phone number (Uzbek format)
  bool get isValidPhone {
    return RegExp(r'^\+998[0-9]{9}$').hasMatch(this);
  }

  // Format phone number
  String get formatPhone {
    if (length != 13 || !startsWith('+998')) return this;
    return '+998 (${substring(4, 6)}) ${substring(6, 9)}-${substring(9, 11)}-${substring(11)}';
  }

  // Remove all whitespaces
  String get removeSpaces => replaceAll(' ', '');

  // Check if string contains only numbers
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  // Check if string is valid password (min 6 chars)
  bool get isValidPassword => length >= 6;

  // Truncate string with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }

  // Convert to snake_case
  String get toSnakeCase {
    return replaceAllMapped(RegExp(r'([A-Z])'), (match) => '_${match.group(1)!.toLowerCase()}')
        .replaceAll(' ', '_')
        .toLowerCase();
  }

  // Convert to camelCase
  String get toCamelCase {
    List<String> parts = split('_');
    if (parts.isEmpty) return this;

    String result = parts[0].toLowerCase();
    for (int i = 1; i < parts.length; i++) {
      result += parts[i].capitalize;
    }
    return result;
  }

  // Check if string is empty or only whitespace
  bool get isBlank => trim().isEmpty;

  // Get file extension
  String get fileExtension {
    int lastDot = lastIndexOf('.');
    if (lastDot == -1) return '';
    return substring(lastDot + 1);
  }

  // Convert attendance status to Uzbek
  String get attendanceStatusUz {
    switch (toLowerCase()) {
      case 'present':
        return 'Bor';
      case 'absent':
        return 'Yo\'q';
      case 'late':
        return 'Kech';
      case 'excused':
        return 'Uzrli';
      default:
        return this;
    }
  }

  // Convert user role to Uzbek
  String get roleUz {
    switch (toLowerCase()) {
      case 'admin':
        return 'Administrator';
      case 'teacher':
        return 'O\'qituvchi';
      case 'student':
        return 'O\'quvchi';
      case 'parent':
        return 'Ota-ona';
      default:
        return this;
    }
  }

  // Format currency (UZS)
  String get formatCurrency {
    return '$this so\'m';
  }
}