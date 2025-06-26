import 'package:json_annotation/json_annotation.dart';
import 'attendance_model.dart';

part 'teacher_models.g.dart';

// Grading table model for homework/exams
@JsonSerializable()
class GradingTableModel {
  final HomeworkExamInfo? homework;
  final HomeworkExamInfo? exam;
  final List<StudentGradeInfo> students;

  const GradingTableModel({
    this.homework,
    this.exam,
    required this.students,
  });

  // Check if this is for homework or exam
  bool get isHomework => homework != null;
  bool get isExam => exam != null;

  // Get the homework/exam info
  HomeworkExamInfo get assignmentInfo => homework ?? exam!;

  // Get assignment type in Uzbek
  String get assignmentTypeUz => isHomework ? 'Vazifa' : 'Imtihon';

  // Get graded students count
  int get gradedStudentsCount {
    return students.where((s) => s.grade.points != null).length;
  }

  // Get ungraded students count
  int get ungradedStudentsCount {
    return students.where((s) => s.grade.points == null).length;
  }

  // Get grading progress percentage
  double get gradingProgress {
    if (students.isEmpty) return 0.0;
    return (gradedStudentsCount / students.length) * 100;
  }

  // Get average grade
  double get averageGrade {
    final gradedStudents = students.where((s) => s.grade.points != null).toList();
    if (gradedStudents.isEmpty) return 0.0;

    double total = 0.0;
    for (final student in gradedStudents) {
      final percentage = (student.grade.points! / assignmentInfo.maxPoints) * 100;
      total += percentage;
    }

    return total / gradedStudents.length;
  }

  // Get grade distribution
  Map<String, int> get gradeDistribution {
    final distribution = <String, int>{
      'A\'lo': 0,
      'Yaxshi': 0,
      'Qoniqarli': 0,
      'Qoniqarsiz': 0,
    };

    for (final student in students) {
      if (student.grade.points != null) {
        final percentage = (student.grade.points! / assignmentInfo.maxPoints) * 100;
        if (percentage >= 90) {
          distribution['A\'lo'] = distribution['A\'lo']! + 1;
        } else if (percentage >= 70) {
          distribution['Yaxshi'] = distribution['Yaxshi']! + 1;
        } else if (percentage >= 50) {
          distribution['Qoniqarli'] = distribution['Qoniqarli']! + 1;
        } else {
          distribution['Qoniqarsiz'] = distribution['Qoniqarsiz']! + 1;
        }
      }
    }

    return distribution;
  }

  // JSON serialization
  factory GradingTableModel.fromJson(Map<String, dynamic> json) => _$GradingTableModelFromJson(json);
  Map<String, dynamic> toJson() => _$GradingTableModelToJson(this);

  @override
  String toString() {
    return 'GradingTableModel(type: $assignmentTypeUz, students: ${students.length}, graded: $gradedStudentsCount)';
  }
}

// Homework/Exam info for grading table
@JsonSerializable()
class HomeworkExamInfo {
  final int id;
  final String title;
  @JsonKey(name: 'max_points')
  final int maxPoints;

  const HomeworkExamInfo({
    required this.id,
    required this.title,
    required this.maxPoints,
  });

  // JSON serialization
  factory HomeworkExamInfo.fromJson(Map<String, dynamic> json) => _$HomeworkExamInfoFromJson(json);
  Map<String, dynamic> toJson() => _$HomeworkExamInfoToJson(this);

  @override
  String toString() {
    return 'HomeworkExamInfo(id: $id, title: $title, maxPoints: $maxPoints)';
  }
}

// Student grade info for grading table
@JsonSerializable()
class StudentGradeInfo {
  @JsonKey(name: 'student_id')
  final int studentId;
  final String name;
  final GradeInfo grade;

  const StudentGradeInfo({
    required this.studentId,
    required this.name,
    required this.grade,
  });

  // Check if student is graded
  bool get isGraded => grade.points != null;

  // Get grade percentage
  double get gradePercentage {
    if (grade.points == null) return 0.0;
    // We need max_points from the assignment, this should be calculated externally
    return 0.0; // Will be calculated in the UI with max_points
  }

  // JSON serialization
  factory StudentGradeInfo.fromJson(Map<String, dynamic> json) => _$StudentGradeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StudentGradeInfoToJson(this);

  @override
  String toString() {
    return 'StudentGradeInfo(studentId: $studentId, name: $name, graded: $isGraded)';
  }
}

// Grade info for grading table
@JsonSerializable()
class GradeInfo {
  final int? points;
  final String comment;

  const GradeInfo({
    this.points,
    required this.comment,
  });

  // JSON serialization
  factory GradeInfo.fromJson(Map<String, dynamic> json) => _$GradeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GradeInfoToJson(this);

  @override
  String toString() {
    return 'GradeInfo(points: $points, comment: ${comment.isEmpty ? "No comment" : comment})';
  }
}

// Grade request for bulk grading
@JsonSerializable()
class GradeRequest {
  @JsonKey(name: 'student_id')
  final int studentId;
  final int points;
  final String comment;

  const GradeRequest({
    required this.studentId,
    required this.points,
    required this.comment,
  });

  // JSON serialization
  factory GradeRequest.fromJson(Map<String, dynamic> json) => _$GradeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GradeRequestToJson(this);

  @override
  String toString() {
    return 'GradeRequest(studentId: $studentId, points: $points)';
  }
}

// Bulk homework grade request
@JsonSerializable()
class BulkHomeworkGradeRequest {
  @JsonKey(name: 'homework_id')
  final int homeworkId;
  final List<GradeRequest> grades;

  const BulkHomeworkGradeRequest({
    required this.homeworkId,
    required this.grades,
  });

  // Get total students being graded
  int get totalStudents => grades.length;

  // JSON serialization
  factory BulkHomeworkGradeRequest.fromJson(Map<String, dynamic> json) => _$BulkHomeworkGradeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BulkHomeworkGradeRequestToJson(this);

  @override
  String toString() {
    return 'BulkHomeworkGradeRequest(homeworkId: $homeworkId, students: $totalStudents)';
  }
}

// Bulk exam grade request
@JsonSerializable()
class BulkExamGradeRequest {
  @JsonKey(name: 'exam_id')
  final int examId;
  final List<GradeRequest> grades;

  const BulkExamGradeRequest({
    required this.examId,
    required this.grades,
  });

  // Get total students being graded
  int get totalStudents => grades.length;

  // JSON serialization
  factory BulkExamGradeRequest.fromJson(Map<String, dynamic> json) => _$BulkExamGradeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$BulkExamGradeRequestToJson(this);

  @override
  String toString() {
    return 'BulkExamGradeRequest(examId: $examId, students: $totalStudents)';
  }
}

// Attendance table model for teacher
@JsonSerializable()
class AttendanceTableModel {
  @JsonKey(name: 'group_subject')
  final GroupSubjectInfo groupSubject;
  @JsonKey(name: 'date_range')
  final DateRangeInfo dateRange;
  final List<String> dates;
  final List<StudentAttendanceInfo> students;

  const AttendanceTableModel({
    required this.groupSubject,
    required this.dateRange,
    required this.dates,
    required this.students,
  });

  // Get total attendance days
  int get totalDays => dates.length;

  // Get attendance statistics
  Map<String, int> get attendanceStats {
    final stats = <String, int>{
      'present': 0,
      'absent': 0,
      'late': 0,
      'excused': 0,
      'not_recorded': 0,
    };

    for (final student in students) {
      for (final entry in student.attendanceByDate.entries) {
        final status = entry.value;
        stats[status] = (stats[status] ?? 0) + 1;
      }
    }

    return stats;
  }

  // Get overall attendance percentage
  double get overallAttendancePercentage {
    if (students.isEmpty || totalDays == 0) return 0.0;

    int totalRecords = students.length * totalDays;
    int presentRecords = attendanceStats['present'] ?? 0;
    int excusedRecords = attendanceStats['excused'] ?? 0;

    return ((presentRecords + excusedRecords) / totalRecords) * 100;
  }

  // JSON serialization
  factory AttendanceTableModel.fromJson(Map<String, dynamic> json) => _$AttendanceTableModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceTableModelToJson(this);

  @override
  String toString() {
    return 'AttendanceTableModel(group: ${groupSubject.groupName}, subject: ${groupSubject.subjectName}, students: ${students.length}, days: $totalDays)';
  }
}

// Group subject info for attendance table
@JsonSerializable()
class GroupSubjectInfo {
  final int id;
  @JsonKey(name: 'group_name')
  final String groupName;
  @JsonKey(name: 'subject_name')
  final String subjectName;

  const GroupSubjectInfo({
    required this.id,
    required this.groupName,
    required this.subjectName,
  });

  // Get display name
  String get displayName => '$groupName - $subjectName';

  // JSON serialization
  factory GroupSubjectInfo.fromJson(Map<String, dynamic> json) => _$GroupSubjectInfoFromJson(json);
  Map<String, dynamic> toJson() => _$GroupSubjectInfoToJson(this);

  @override
  String toString() {
    return 'GroupSubjectInfo(id: $id, displayName: $displayName)';
  }
}

// Date range info for attendance table
@JsonSerializable()
class DateRangeInfo {
  @JsonKey(name: 'start_date')
  final DateTime? startDate;
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @JsonKey(name: 'total_dates')
  final int totalDates;

  const DateRangeInfo({
    this.startDate,
    this.endDate,
    required this.totalDates,
  });

  // Get date range text
  String get dateRangeText {
    if (startDate == null || endDate == null) return 'Barcha sanalar';

    final start = '${startDate!.day}.${startDate!.month}.${startDate!.year}';
    final end = '${endDate!.day}.${endDate!.month}.${endDate!.year}';

    return '$start - $end';
  }

  // JSON serialization
  factory DateRangeInfo.fromJson(Map<String, dynamic> json) => _$DateRangeInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DateRangeInfoToJson(this);

  @override
  String toString() {
    return 'DateRangeInfo(range: $dateRangeText, totalDates: $totalDates)';
  }
}

// Student attendance info for attendance table
@JsonSerializable()
class StudentAttendanceInfo {
  @JsonKey(name: 'student_id')
  final int studentId;
  final String name;
  @JsonKey(name: 'attendance_by_date')
  final Map<String, String> attendanceByDate;
  final AttendanceStats summary;

  const StudentAttendanceInfo({
    required this.studentId,
    required this.name,
    required this.attendanceByDate,
    required this.summary,
  });

  // Get attendance percentage
  double get attendancePercentage => summary.attendancePercentage;

  // Get attendance status
  String get attendanceStatus => summary.attendanceStatus;

  // Get attendance for specific date
  String getAttendanceForDate(String date) {
    return attendanceByDate[date] ?? 'not_recorded';
  }

  // JSON serialization
  factory StudentAttendanceInfo.fromJson(Map<String, dynamic> json) => _$StudentAttendanceInfoFromJson(json);
  Map<String, dynamic> toJson() => _$StudentAttendanceInfoToJson(this);

  @override
  String toString() {
    return 'StudentAttendanceInfo(studentId: $studentId, name: $name, attendance: ${attendancePercentage.toStringAsFixed(1)}%)';
  }
}