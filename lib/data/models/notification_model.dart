import 'package:json_annotation/json_annotation.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final String title;
  final String message;
  final String type;
  @JsonKey(name: 'is_read')
  final bool isRead;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
  });

  // Notification type constants
  static const String homework = 'homework';
  static const String exam = 'exam';
  static const String grade = 'grade';
  static const String attendance = 'attendance';
  static const String payment = 'payment';
  static const String general = 'general';

  // Check notification type
  bool get isHomework => type == homework;
  bool get isExam => type == exam;
  bool get isGrade => type == grade;
  bool get isAttendance => type == attendance;
  bool get isPayment => type == payment;
  bool get isGeneral => type == general;

  // Get notification icon
  String get notificationIcon {
    switch (type) {
      case homework:
        return '📝';
      case exam:
        return '📋';
      case grade:
        return '🎯';
      case attendance:
        return '📅';
      case payment:
        return '💰';
      case general:
        return '📢';
      default:
        return '🔔';
    }
  }

  // Get notification color (as hex string)
  String get notificationColor {
    switch (type) {
      case homework:
        return '#2196F3'; // Blue
      case exam:
        return '#9C27B0'; // Purple
      case grade:
        return '#4CAF50'; // Green
      case attendance:
        return '#00BCD4'; // Teal
      case payment:
        return '#FF9800'; // Orange
      case general:
        return '#607D8B'; // Blue Grey
      default:
        return '#9E9E9E'; // Grey
    }
  }

  // Get type in Uzbek
  String get typeUz {
    switch (type) {
      case homework:
        return 'Vazifa';
      case exam:
        return 'Imtihon';
      case grade:
        return 'Baho';
      case attendance:
        return 'Davomat';
      case payment:
        return 'To\'lov';
      case general:
        return 'Umumiy';
      default:
        return 'Bildirishnoma';
    }
  }

  // Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

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

  // Get formatted date
  String get formattedDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = createdAt.day;
    final month = months[createdAt.month];
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$day $month $year, $hour:$minute';
  }

  // Get short formatted date
  String get shortFormattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    final year = createdAt.year;
    final hour = createdAt.hour.toString().padLeft(2, '0');
    final minute = createdAt.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }

  // Check if notification is new (within last hour)
  bool get isNew {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    return difference.inHours < 1;
  }

  // Check if notification is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final notificationDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return today.isAtSameMomentAs(notificationDay);
  }

  // Check if notification is from yesterday
  bool get isYesterday {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final notificationDay = DateTime(createdAt.year, createdAt.month, createdAt.day);
    return yesterday.isAtSameMomentAs(notificationDay);
  }

  // Get priority level (for sorting)
  int get priorityLevel {
    if (isRead) return 0; // Lowest priority if read

    switch (type) {
      case exam:
        return 5; // Highest priority
      case grade:
        return 4;
      case homework:
        return 3;
      case attendance:
        return 2;
      case payment:
        return 2;
      case general:
        return 1;
      default:
        return 1;
    }
  }

  // Get notification summary for display
  String get summary {
    if (message.length <= 50) return message;
    return '${message.substring(0, 47)}...';
  }

  // JSON serialization
  factory NotificationModel.fromJson(Map<String, dynamic> json) => _$NotificationModelFromJson(json);
  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);

  // Copy with method
  NotificationModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotificationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'NotificationModel(id: $id, title: $title, type: $typeUz, isRead: $isRead, timeAgo: $timeAgo)';
  }
}

// Unread count response model
@JsonSerializable()
class UnreadCountModel {
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const UnreadCountModel({
    required this.unreadCount,
  });

  // Check if has unread notifications
  bool get hasUnread => unreadCount > 0;

  // Get display text
  String get displayText {
    if (unreadCount == 0) return 'Yangi bildirishnomalar yo\'q';
    if (unreadCount == 1) return '1 yangi bildirishnoma';
    if (unreadCount < 10) return '$unreadCount yangi bildirishnoma';
    return '9+ yangi bildirishnoma';
  }

  // Get badge text (for UI)
  String get badgeText {
    if (unreadCount == 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  // JSON serialization
  factory UnreadCountModel.fromJson(Map<String, dynamic> json) => _$UnreadCountModelFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountModelToJson(this);

  @override
  String toString() {
    return 'UnreadCountModel(unreadCount: $unreadCount)';
  }
}