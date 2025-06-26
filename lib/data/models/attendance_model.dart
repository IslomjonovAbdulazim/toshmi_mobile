import 'package:json_annotation/json_annotation.dart';

part 'attendance_model.g.dart';

@JsonSerializable()
class AttendanceModel {
  final int? id;
  @JsonKey(name: 'student_id')
  final int? studentId;
  @JsonKey(name: 'group_subject_id')
  final int? groupSubjectId;
  final DateTime date;
  final String status;

  // From API responses with joined data
  final String? subject; // group_subject.subject.name
  final String? teacher; // group_subject.teacher.full_name

  const AttendanceModel({
    this.id,
    this.studentId,
    this.groupSubjectId,
    required this.date,
    required this.status,
    this.subject,
    this.teacher,
  });

  // Attendance status constants
  static const String present = 'present';
  static const String absent = 'absent';
  static const String late = 'late';
  static const String excused = 'excused';
  static const String notRecorded = 'not_recorded';

  // Check attendance status
  bool get isPresent => status == present;
  bool get isAbsent => status == absent;
  bool get isLate => status == late;
  bool get isExcused => status == excused;
  bool get isNotRecorded => status == notRecorded;

  // Get status in Uzbek
  String get statusUz {
    switch (status) {
      case present:
        return 'Kelgan';
      case absent:
        return 'Kelmagan';
      case late:
        return 'Kech kelgan';
      case excused:
        return 'Uzrli';
      case notRecorded:
        return 'Belgilanmagan';
      default:
        return status;
    }
  }

  // Get status icon
  String get statusIcon {
    switch (status) {
      case present:
        return '✅';
      case absent:
        return '❌';
      case late:
        return '⏰';
      case excused:
        return '📝';
      case notRecorded:
        return '❓';
      default:
        return '❓';
    }
  }

  // Get status color (as hex string)
  String get statusColor {
    switch (status) {
      case present:
        return '#4CAF50'; // Green
      case absent:
        return '#F44336'; // Red
      case late:
        return '#FF9800'; // Orange
      case excused:
        return '#9C27B0'; // Purple
      case notRecorded:
        return '#9E9E9E'; // Gray
      default:
        return '#9E9E9E'; // Gray
    }
  }

  // Get display subject
  String get displaySubject => subject ?? 'Fan noma\'lum';

  // Get display teacher
  String get displayTeacher => teacher ?? 'Ustoz noma\'lum';

  // Get formatted date
  String get formattedDate {
    final months = [
      '', 'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
      'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr'
    ];

    final day = date.day;
    final month = months[date.month];
    final year = date.year;

    return '$day $month $year';
  }

  // Get short formatted date
  String get shortFormattedDate {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;

    return '$day.$month.$year';
  }

  // Get weekday in Uzbek
  String get weekdayUz {
    const weekdays = [
      'Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba',
      'Juma', 'Shanba', 'Yakshanba'
    ];
    return weekdays[date.weekday - 1];
  }

  // Check if attendance is positive (present or excused)
  bool get isPositive => isPresent || isExcused;

  // Check if attendance is negative (absent or late)
  bool get isNegative => isAbsent || isLate;

  // Get attendance score for calculations (1 = present, 0.5 = late/excused, 0 = absent)
  double get attendanceScore {
    switch (status) {
      case present:
        return 1.0;
      case late:
      case excused:
        return 0.5;
      case absent:
        return 0.0;
      default:
        return 0.0;
    }
  }

  // Check if attendance is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final attendanceDay = DateTime(date.year, date.month, date.day);
    return today.isAtSameMomentAs(attendanceDay);
  }

  // Check if attendance is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final attendanceDay = DateTime(date.year, date.month, date.day);
    return attendanceDay.isAfter(startDay.subtract(const Duration(days: 1))) &&
        attendanceDay.isBefore(startDay.add(const Duration(days: 7)));
  }

  // JSON serialization
  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);

  // Copy with method
  AttendanceModel copyWith({
    int? id,
    int? studentId,
    int? groupSubjectId,
    DateTime? date,
    String? status,
    String? subject,
    String? teacher,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      date: date ?? this.date,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      teacher: teacher ?? this.teacher,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel &&
        other.date == date &&
        other.studentId == studentId &&
        other.groupSubjectId == groupSubjectId;
  }

  @override
  int get hashCode => Object.hash(date, studentId, groupSubjectId);

  @override
  String toString() {
    return 'AttendanceModel(date: $shortFormattedDate, status: $statusUz, subject: $displaySubject)';
  }
}

// Attendance record for bulk operations (teacher endpoint)
@JsonSerializable()
class AttendanceRecord {
  @JsonKey(name: 'student_id')
  final int studentId;
  final String status;

  const AttendanceRecord({
    required this.studentId,
    required this.status,
  });

  // JSON serialization
  factory AttendanceRecord.fromJson(Map<String, dynamic> json) => _$AttendanceRecordFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceRecordToJson(this);

  @override
  String toString() {
    return 'AttendanceRecord(studentId: $studentId, status: $status)';
  }
}

// Bulk attendance request for teacher endpoint
@JsonSerializable()
class BulkAttendanceRequest {
  @JsonKey(name: 'group_subject_id')
  final int groupSubjectId;
  final DateTime date;
  final List<AttendanceRecord> records;

  const BulkAttendanceRequest({
    required this.groupSubjectId,
    required this.date,
    required this.records,
  });

  // JSON serialization
  factory BulkAttendanceRequest.fromJson(Map<String, dynamic> json) => _$BulkAttendanceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BulkAttendanceRequestToJson(this);

  @override
  String toString() {
    return 'BulkAttendanceRequest(groupSubjectId: $groupSubjectId, date: $date, records: ${records.length})';
  }
}

// Attendance statistics model
@JsonSerializable()
class AttendanceStats {
  final int present;
  final int absent;
  final int late;
  final int excused;
  @JsonKey(name: 'total_days')
  final int totalDays;

  const AttendanceStats({
    required this.present,
    required this.absent,
    required this.late,
    required this.excused,
    required this.totalDays,
  });

  // Calculate attendance percentage
  double get attendancePercentage {
    if (totalDays == 0) return 0.0;
    return (present / totalDays) * 100;
  }

  // Calculate adjusted attendance percentage (including partial credit for late/excused)
  double get adjustedAttendancePercentage {
    if (totalDays == 0) return 0.0;
    final adjustedPresent = present + (late * 0.5) + (excused * 0.5);
    return (adjustedPresent / totalDays) * 100;
  }

  // Get attendance status
  String get attendanceStatus {
    final percentage = attendancePercentage;
    if (percentage >= 90) return 'A\'lo';
    if (percentage >= 80) return 'Yaxshi';
    if (percentage >= 70) return 'Qoniqarli';
    return 'Qoniqarsiz';
  }

  // JSON serialization
  factory AttendanceStats.fromJson(Map<String, dynamic> json) => _$AttendanceStatsFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceStatsToJson(this);

  @override
  String toString() {
    return 'AttendanceStats(present: $present/$totalDays, percentage: ${attendancePercentage.toStringAsFixed(1)}%)';
  }
}