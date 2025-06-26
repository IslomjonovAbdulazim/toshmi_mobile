import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// ===================== DATE EXTENSIONS =====================

extension DateTimeExtensions on DateTime {
  /// Format date as dd.MM.yyyy
  String get formattedDate => DateFormat('dd.MM.yyyy').format(this);

  /// Format time as HH:mm
  String get formattedTime => DateFormat('HH:mm').format(this);

  /// Format date and time as dd.MM.yyyy HH:mm
  String get formattedDateTime => DateFormat('dd.MM.yyyy HH:mm').format(this);

  /// Format date as dd.MM
  String get shortDate => DateFormat('dd.MM').format(this);

  /// Format date in Uzbek style (1 Yanvar 2024)
  String get uzbekDate {
    const months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return '$day ${months[month]} $year';
  }

  /// Format date in Uzbek style with time (1 Yanvar 2024, 14:30)
  String get uzbekDateTime => '$uzbekDate, $formattedTime';

  /// Get weekday name in Uzbek
  String get uzbekWeekday {
    const weekdays = [
      '', 'Dushanba', 'Seshanba', 'Chorshanba',
      'Payshanba', 'Juma', 'Shanba', 'Yakshanba'
    ];
    return weekdays[weekday];
  }

  /// Get month name in Uzbek
  String get uzbekMonth {
    const months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return months[month];
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Check if date is this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
        isBefore(endOfWeek.add(const Duration(days: 1)));
  }

  /// Check if date is this month
  bool get isThisMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }

  /// Get time ago in Uzbek
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(this);

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
  String get timeUntil {
    final now = DateTime.now();
    final difference = this.difference(now);

    if (difference.isNegative) return timeAgo;

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

  /// Get start of day (00:00:00)
  DateTime get startOfDay => DateTime(year, month, day);

  /// Get end of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Get start of week (Monday)
  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  /// Get end of week (Sunday)
  DateTime get endOfWeek => add(Duration(days: 7 - weekday)).endOfDay;

  /// Get start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// Get end of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Add business days (excluding weekends)
  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.weekday < 6) { // Monday = 1, Friday = 5
        addedDays++;
      }
    }

    return result;
  }

  /// Check if it's a weekend
  bool get isWeekend => weekday == DateTime.saturday || weekday == DateTime.sunday;

  /// Check if it's a working day
  bool get isWorkingDay => !isWeekend;
}
