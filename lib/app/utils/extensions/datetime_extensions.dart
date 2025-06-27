extension DateTimeExtensions on DateTime {
  // Format date as dd.MM.yyyy
  String get formatDate => '${day.toString().padLeft(2, '0')}.${month.toString().padLeft(2, '0')}.$year';

  // Format time as HH:mm
  String get formatTime => '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  // Format date and time as dd.MM.yyyy HH:mm
  String get formatDateTime => '$formatDate $formatTime';

  // Get day name in Uzbek
  String get dayNameUz {
    const days = ['Yakshanba', 'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'];
    return days[weekday % 7];
  }

  // Get month name in Uzbek
  String get monthNameUz {
    const months = [
      'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];
    return months[month - 1];
  }

  // Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  // Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  // Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  // Get relative time string
  String get relativeTime {
    if (isToday) return 'Bugun';
    if (isYesterday) return 'Kecha';
    if (isTomorrow) return 'Ertaga';

    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return '1 kun oldin';
      if (difference.inDays < 7) return '${difference.inDays} kun oldin';
      if (difference.inDays < 30) return '${(difference.inDays / 7).floor()} hafta oldin';
      if (difference.inDays < 365) return '${(difference.inDays / 30).floor()} oy oldin';
      return '${(difference.inDays / 365).floor()} yil oldin';
    } else {
      final futureDiff = difference.abs();
      if (futureDiff.inDays == 1) return '1 kun keyin';
      if (futureDiff.inDays < 7) return '${futureDiff.inDays} kun keyin';
      if (futureDiff.inDays < 30) return '${(futureDiff.inDays / 7).floor()} hafta keyin';
      return formatDate;
    }
  }

  // Get start of day
  DateTime get startOfDay => DateTime(year, month, day);

  // Get end of day
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  // Check if date is in current week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return isAfter(startOfWeek.startOfDay) && isBefore(endOfWeek.endOfDay);
  }
}