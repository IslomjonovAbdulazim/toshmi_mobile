
// ===================== STRING EXTENSIONS =====================

import 'package:intl/intl.dart';

extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  /// Capitalize each word
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalized).join(' ');
  }

  /// Remove extra whitespaces
  String get trimmed => trim().replaceAll(RegExp(r'\s+'), ' ');

  /// Check if string is valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  /// Check if string is valid phone number
  bool get isValidPhone {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  /// Check if string is numeric
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Check if string is integer
  bool get isInteger {
    return int.tryParse(this) != null;
  }

  /// Convert to integer safely
  int? get toInt => int.tryParse(this);

  /// Convert to double safely
  double? get toDouble => double.tryParse(this);

  /// Get initials from full name
  String get initials {
    final words = trimmed.split(' ');
    if (words.isEmpty) return '';
    if (words.length == 1) return words[0][0].toUpperCase();
    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  /// Mask phone number (+998 ** *** ** **)
  String get maskedPhone {
    if (length < 8) return this;
    final start = substring(0, 4);
    final end = substring(length - 2);
    final middle = '*' * (length - 6);
    return '$start$middle$end';
  }

  /// Mask email (user***@domain.com)
  String get maskedEmail {
    final parts = split('@');
    if (parts.length != 2) return this;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 3) return this;

    final visiblePart = username.substring(0, 3);
    final maskedPart = '*' * (username.length - 3);

    return '$visiblePart$maskedPart@$domain';
  }

  /// Remove Uzbek diacritics for search
  String get normalized {
    return replaceAll('ʻ', '\'')
        .replaceAll('ʼ', '\'')
        .replaceAll('ʹ', '\'')
        .replaceAll('`', '\'')
        .toLowerCase();
  }

  /// Truncate string with ellipsis
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  /// Convert to snake_case
  String get snakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst(RegExp(r'^_'), '');
  }

  /// Convert to camelCase
  String get camelCase {
    final words = split(RegExp(r'[_\s]+'));
    if (words.isEmpty) return this;

    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((word) => word.capitalized);

    return first + rest.join();
  }

  /// Parse DateTime from string
  DateTime? get toDateTime {
    try {
      // Try different formats
      final formats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd',
        'dd.MM.yyyy HH:mm',
        'dd.MM.yyyy',
        'dd/MM/yyyy',
      ];

      for (final format in formats) {
        try {
          return DateFormat(format).parse(this);
        } catch (e) {
          // Continue to next format
        }
      }

      // Try ISO format
      return DateTime.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Format as file size
  String formatAsFileSize() {
    final bytes = toInt;
    if (bytes == null) return this;

    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Check if string contains Uzbek characters
  bool get hasUzbekChars {
    return contains(RegExp(r'[ʻʼʹ`ғғҳҳқққўўҟҟҳҳ]'));
  }

  /// Remove HTML tags
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  /// Count words
  int get wordCount {
    return trimmed.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;
  }
}