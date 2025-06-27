import 'package:flutter/material.dart';

class DateHelper {
  // Parse date string to DateTime
  static DateTime? parseDate(String date) {
    try {
      return DateTime.parse(date);
    } catch (e) {
      return null;
    }
  }

  // Format date for API (yyyy-MM-dd)
  static String formatForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Get academic year from date
  static String getAcademicYear(DateTime date) {
    if (date.month >= 9) {
      return '${date.year}-${date.year + 1}';
    } else {
      return '${date.year - 1}-${date.year}';
    }
  }

  // Get current academic year
  static String getCurrentAcademicYear() {
    return getAcademicYear(DateTime.now());
  }

  // Check if date is in school time (Mon-Sat, 8:00-18:00)
  static bool isSchoolTime(DateTime date) {
    if (date.weekday == 7) return false; // Sunday
    final hour = date.hour;
    return hour >= 8 && hour <= 18;
  }

  // Get age from birth date
  static int calculateAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Get days until date
  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    return difference.inDays;
  }

  // Show date picker
  static Future<DateTime?> showDatePicker(
    BuildContext context, {
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    return await showDatePicker(
      context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
  }

  // Show time picker
  static Future<TimeOfDay?> showTimePicker(
    BuildContext context, {
    TimeOfDay? initialTime,
  }) async {
    return await showTimePicker(
      context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }

  // Get week dates (Monday to Sunday)
  static List<DateTime> getWeekDates(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  // Get month dates
  static List<DateTime> getMonthDates(DateTime date) {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);
    return List.generate(
      lastDay.day,
      (index) => DateTime(date.year, date.month, index + 1),
    );
  }

  // Check if date is weekend
  static bool isWeekend(DateTime date) {
    return date.weekday == 6 || date.weekday == 7; // Saturday or Sunday
  }

  // Get next school day
  static DateTime getNextSchoolDay(DateTime date) {
    DateTime nextDay = date.add(const Duration(days: 1));
    while (nextDay.weekday == 7) {
      // Skip Sunday
      nextDay = nextDay.add(const Duration(days: 1));
    }
    return nextDay;
  }
}
