// New models for teacher group-subjects and schedule endpoints

class GroupSubject {
  final int id;
  final int groupId;
  final int subjectId;
  final int teacherId;
  final String groupName;
  final String subjectName;
  final String subjectCode;

  GroupSubject({
    required this.id,
    required this.groupId,
    required this.subjectId,
    required this.teacherId,
    required this.groupName,
    required this.subjectName,
    required this.subjectCode,
  });

  factory GroupSubject.fromJson(Map<String, dynamic> json) {
    return GroupSubject(
      id: json['id'],
      groupId: json['group_id'],
      subjectId: json['subject_id'],
      teacherId: json['teacher_id'],
      groupName: json['group_name'],
      subjectName: json['subject_name'],
      subjectCode: json['subject_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'subject_id': subjectId,
      'teacher_id': teacherId,
      'group_name': groupName,
      'subject_name': subjectName,
      'subject_code': subjectCode,
    };
  }

  GroupSubject copyWith({
    int? id,
    int? groupId,
    int? subjectId,
    int? teacherId,
    String? groupName,
    String? subjectName,
    String? subjectCode,
  }) {
    return GroupSubject(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      groupName: groupName ?? this.groupName,
      subjectName: subjectName ?? this.subjectName,
      subjectCode: subjectCode ?? this.subjectCode,
    );
  }
}

class TeacherSchedule {
  final int id;
  final int day;
  final String dayName;
  final String startTime; // HH:MM:SS format
  final String endTime;   // HH:MM:SS format
  final String room;

  TeacherSchedule({
    required this.id,
    required this.day,
    required this.dayName,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      id: json['id'],
      day: json['day'],
      dayName: json['day_name'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      room: json['room'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'day': day,
      'day_name': dayName,
      'start_time': startTime,
      'end_time': endTime,
      'room': room,
    };
  }

  TeacherSchedule copyWith({
    int? id,
    int? day,
    String? dayName,
    String? startTime,
    String? endTime,
    String? room,
  }) {
    return TeacherSchedule(
      id: id ?? this.id,
      day: day ?? this.day,
      dayName: dayName ?? this.dayName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }

  // Helper method to get formatted time display (HH:MM)
  String get formattedStartTime {
    return startTime.substring(0, 5); // "09:00:00" -> "09:00"
  }

  String get formattedEndTime {
    return endTime.substring(0, 5); // "10:30:00" -> "10:30"
  }

  // Helper method to get time range display
  String get timeRange {
    return '${formattedStartTime} - ${formattedEndTime}';
  }
}