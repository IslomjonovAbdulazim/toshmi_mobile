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

  // Type constants
  static const String homework = 'homework';
  static const String exam = 'exam';
  static const String grade = 'grade';
  static const String attendance = 'attendance';
  static const String payment = 'payment';
  static const String announcement = 'announcement';

  // Computed properties
  String get typeUz => switch (type) {
    homework => 'Vazifa',
    exam => 'Imtihon',
    grade => 'Baho',
    attendance => 'Davomat',
    payment => 'To\'lov',
    announcement => 'E\'lon',
    _ => 'Bildirishnoma',
  };

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} kun oldin';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} soat oldin';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} daqiqa oldin';
    } else {
      return 'Hozirgina';
    }
  }

  String get priorityIcon => switch (type) {
    homework => '📚',
    exam => '📝',
    grade => '⭐',
    attendance => '📅',
    payment => '💳',
    announcement => '📢',
    _ => '🔔',
  };

  bool get isImportant => type == exam || type == payment;
  bool get isRecent => DateTime.now().difference(createdAt).inHours < 24;

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
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NotificationModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'NotificationModel(id: $id, title: $title, type: $typeUz, isRead: $isRead)';
}

@JsonSerializable()
class UnreadCountModel {
  @JsonKey(name: 'unread_count')
  final int unreadCount;

  const UnreadCountModel({required this.unreadCount});

  bool get hasUnread => unreadCount > 0;

  String get displayText {
    if (unreadCount == 0) return 'Yangi bildirishnomalar yo\'q';
    if (unreadCount == 1) return '1 yangi bildirishnoma';
    if (unreadCount < 10) return '$unreadCount yangi bildirishnoma';
    return '9+ yangi bildirishnoma';
  }

  String get badgeText {
    if (unreadCount == 0) return '';
    if (unreadCount > 99) return '99+';
    return unreadCount.toString();
  }

  factory UnreadCountModel.fromJson(Map<String, dynamic> json) => _$UnreadCountModelFromJson(json);
  Map<String, dynamic> toJson() => _$UnreadCountModelToJson(this);

  @override
  String toString() => 'UnreadCountModel(unreadCount: $unreadCount)';
}