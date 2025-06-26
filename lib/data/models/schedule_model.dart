import 'package:json_annotation/json_annotation.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  final int? id;
  @JsonKey(name: 'group_subject_id')
  final int? groupSubjectId;
  final int day; // 0 = Monday, 1 = Tuesday, ..., 6 = Sunday
  @JsonKey(name: 'start_time', fromJson: _timeFromJson, toJson: _timeToJson)
  final DateTime startTime;
  @JsonKey(name: 'end_time', fromJson: _timeFromJson, toJson: _timeToJson)
  final DateTime endTime;
  final String? room;

  // From API responses with joined data
  final String? subject; // group_subject.subject.name
  final String? teacher; // group_subject.teacher.full_name

  const ScheduleModel({
    this.id,
    this.groupSubjectId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.room,
    this.subject,
    this.teacher,
  });

  // Day constants
  static const int monday = 0;
  static const int tuesday = 1;
  static const int wednesday = 2;
  static const int thursday = 3;
  static const int friday = 4;
  static const int saturday = 5;
  static const int sunday = 6;

  // Get day name in Uzbek
  String get dayNameUz {
    const dayNames = [
      'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
      'Juma', 'Shanba', 'Yakshanba'
    ];
    return day >= 0 && day < dayNames.length ? dayNames[day] : 'Noma\'lum';
  }

  // Get short day name in Uzbek
  String get shortDayNameUz {
    const shortDayNames = [
      'Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'
    ];
    return day >= 0 && day < shortDayNames.length ? shortDayNames[day] : '??';
  }

  // Get formatted start time
  String get formattedStartTime {
    final hour = startTime.hour.toString().padLeft(2, '0');
    final minute = startTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get formatted end time
  String get formattedEndTime {
    final hour = endTime.hour.toString().padLeft(2, '0');
    final minute = endTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // Get time range
  String get timeRange => '$formattedStartTime - $formattedEndTime';

  // Get duration in minutes
  int get durationInMinutes {
    return endTime.difference(startTime).inMinutes;
  }

  // Get formatted duration
  String get formattedDuration {
    final hours = durationInMinutes ~/ 60;
    final minutes = durationInMinutes % 60;

    if (hours > 0 && minutes > 0) {
      return '${hours}s ${minutes}d';
    } else if (hours > 0) {
      return '${hours}s';
    } else {
      return '${minutes}d';
    }
  }

  // Get display subject
  String get displaySubject => subject ?? 'Fan noma\'lum';

  // Get display teacher
  String get displayTeacher => teacher ?? 'Ustoz noma\'lum';

  // Get display room
  String get displayRoom => room ?? 'Xona ko\'rsatilmagan';

  // Check if schedule is for today
  bool get isToday => day == DateTime.now().weekday - 1;

  // Check if schedule is currently active
  bool get isCurrentlyActive {
    if (!isToday) return false;

    final now = DateTime.now();
    final currentTime = DateTime(2000, 1, 1, now.hour, now.minute);
    final scheduleStart = DateTime(2000, 1, 1, startTime.hour, startTime.minute);
    final scheduleEnd = DateTime(2000, 1, 1, endTime.hour, endTime.minute);

    return currentTime.isAfter(scheduleStart) && currentTime.isBefore(scheduleEnd);
  }

  // Check if schedule is upcoming today
  bool get isUpcomingToday {
    if (!isToday) return false;

    final now = DateTime.now();
    final currentTime = DateTime(2000, 1, 1, now.hour, now.minute);
    final scheduleStart = DateTime(2000, 1, 1, startTime.hour, startTime.minute);

    return currentTime.isBefore(scheduleStart);
  }

  // Get status for today
  String get todayStatus {
    if (!isToday) return '';
    if (isCurrentlyActive) return 'Hozir';
    if (isUpcomingToday) return 'Keyingi';
    return 'O\'tgan';
  }

  // Get status color
  String get statusColor {
    if (!isToday) return '#9E9E9E'; // Gray
    if (isCurrentlyActive) return '#4CAF50'; // Green
    if (isUpcomingToday) return '#FF9800'; // Orange
    return '#9E9E9E'; // Gray
  }

  // Get next occurrence of this schedule
  DateTime get nextOccurrence {
    final now = DateTime.now();
    final currentDay = now.weekday - 1; // Convert to 0-6 format

    int daysUntil = day - currentDay;
    if (daysUntil < 0 || (daysUntil == 0 && now.hour >= endTime.hour)) {
      daysUntil += 7; // Next week
    }

    final nextDate = now.add(Duration(days: daysUntil));
    return DateTime(
      nextDate.year,
      nextDate.month,
      nextDate.day,
      startTime.hour,
      startTime.minute,
    );
  }

  // Compare schedules for sorting
  int compareTo(ScheduleModel other) {
    if (day != other.day) return day.compareTo(other.day);
    return startTime.compareTo(other.startTime);
  }

  // JSON serialization helpers
  static DateTime _timeFromJson(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(2000, 1, 1, hour, minute); // Use a fixed date for time-only values
  }

  static String _timeToJson(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  // JSON serialization
  factory ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);

  // Copy with method
  ScheduleModel copyWith({
    int? id,
    int? groupSubjectId,
    int? day,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    String? subject,
    String? teacher,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScheduleModel &&
        other.day == day &&
        other.startTime == startTime &&
        other.groupSubjectId == groupSubjectId;
  }

  @override
  int get hashCode => Object.hash(day, startTime, groupSubjectId);

  @override
  String toString() {
    return 'ScheduleModel(day: $dayNameUz, time: $timeRange, subject: $displaySubject, room: $displayRoom)';
  }
}

// Schedule request model for creating/updating schedules
@JsonSerializable()
class ScheduleRequest {
  @JsonKey(name: 'group_subject_id')
  final int groupSubjectId;
  final int day;
  @JsonKey(name: 'start_time')
  final String startTime; // "HH:MM" format
  @JsonKey(name: 'end_time')
  final String endTime; // "HH:MM" format
  final String room;

  const ScheduleRequest({
    required this.groupSubjectId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  // JSON serialization
  factory ScheduleRequest.fromJson(Map<String, dynamic> json) => _$ScheduleRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleRequestToJson(this);

  @override
  String toString() {
    return 'ScheduleRequest(groupSubjectId: $groupSubjectId, day: $day, time: $startTime-$endTime, room: $room)';
  }
}