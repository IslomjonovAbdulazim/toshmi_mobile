import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateUtils {
  /// Format date in Uzbek style
  static String formatUzbekDate(DateTime date) {
    const months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  /// Get weekday name in Uzbek
  static String getUzbekWeekday(int weekday) {
    const weekdays = [
      '', 'Dushanba', 'Seshanba', 'Chorshanba',
      'Payshanba', 'Juma', 'Shanba', 'Yakshanba'
    ];
    return weekdays[weekday];
  }

  /// Get time ago in Uzbek
  static String getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqa oldin';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks hafta oldin';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months oy oldin';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years yil oldin';
    }
  }

  /// Get time until in Uzbek
  static String getTimeUntil(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.isNegative) return getTimeAgo(dateTime);

    if (difference.inMinutes < 1) {
      return 'Hozirgina';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} daqiqadan so\'ng';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} soatdan so\'ng';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} kundan so\'ng';
    } else if (difference.inDays < 30) {
      final weeks = difference.inDays ~/ 7;
      return '$weeks haftadan so\'ng';
    } else if (difference.inDays < 365) {
      final months = difference.inDays ~/ 30;
      return '$months oydan so\'ng';
    } else {
      final years = difference.inDays ~/ 365;
      return '$years yildan so\'ng';
    }
  }

  /// Check if date is due soon (within specified days)
  static bool isDueSoon(DateTime dueDate, {int days = 3}) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return difference.inDays >= 0 && difference.inDays <= days;
  }

  /// Check if date is overdue
  static bool isOverdue(DateTime dueDate) {
    return DateTime.now().isAfter(dueDate);
  }

  /// Get academic year from date
  static String getAcademicYear(DateTime date) {
    final year = date.year;
    final month = date.month;

    if (month >= 9) {
      return '$year-${year + 1}';
    } else {
      return '${year - 1}-$year';
    }
  }

  /// Get semester from date (1 or 2)
  static int getSemester(DateTime date) {
    final month = date.month;

    if (month >= 9 || month <= 1) {
      return 1; // First semester: September - January
    } else {
      return 2; // Second semester: February - June
    }
  }

  /// Get days until date
  static int getDaysUntil(DateTime targetDate) {
    final now = DateTime.now();
    final difference = targetDate.difference(now);
    return difference.inDays;
  }

  /// Parse multiple date formats
  static DateTime? parseFlexibleDate(String dateString) {
    final formats = [
      'yyyy-MM-dd HH:mm:ss',
      'yyyy-MM-dd',
      'dd.MM.yyyy HH:mm',
      'dd.MM.yyyy',
      'dd/MM/yyyy',
      'MM/dd/yyyy',
    ];

    for (final format in formats) {
      try {
        return DateFormat(format).parse(dateString);
      } catch (e) {
        // Continue to next format
      }
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      print('DateUtils: Could not parse date: $dateString');
      return null;
    }
  }

  /// Get date range for current week
  static DateTimeRange getCurrentWeek() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));

    return DateTimeRange(
      start: startOfWeek,
      end: endOfWeek,
    );
  }

  /// Get date range for current month
  static DateTimeRange getCurrentMonth() {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);

    return DateTimeRange(
      start: startOfMonth,
      end: endOfMonth,
    );
  }

  /// Format date as dd.MM.yyyy
  static String formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  /// Format time as HH:mm
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  }

  /// Get relative date in Uzbek
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDay = DateTime(date.year, date.month, date.day);

    final difference = targetDay.difference(today).inDays;

    if (difference == 0) {
      return 'Bugun';
    } else if (difference == 1) {
      return 'Ertaga';
    } else if (difference == -1) {
      return 'Kecha';
    } else if (difference > 1 && difference <= 7) {
      return getUzbekWeekday(date.weekday);
    } else {
      return formatUzbekDate(date);
    }
  }

  /// Check if it's a working day
  static bool isWorkingDay(DateTime date) {
    return date.weekday < 6; // Monday = 1, Friday = 5
  }

  /// Check if it's weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7; // Saturday = 6, Sunday = 7
  }

  /// Add business days (excluding weekends)
  static DateTime addBusinessDays(DateTime date, int days) {
    DateTime result = date;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (isWorkingDay(result)) {
        addedDays++;
      }
    }

    return result;
  }

  /// Get start of day (00:00:00)
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59)
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }

  /// Get start of week (Monday)
  static DateTime startOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  /// Get end of week (Sunday)
  static DateTime endOfWeek(DateTime date) {
    return date.add(Duration(days: 7 - date.weekday));
  }
}