import 'package:flutter/material.dart';

class Schedule {
  final int id;
  final int groupSubjectId;
  final int day;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final String room;

  Schedule({
    required this.id,
    required this.groupSubjectId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.room,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      groupSubjectId: json['group_subject_id'],
      day: json['day'],
      startTime: _parseTimeString(json['start_time']),
      endTime: _parseTimeString(json['end_time']),
      room: json['room'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_subject_id': groupSubjectId,
      'day': day,
      'start_time': _formatTimeOfDay(startTime),
      'end_time': _formatTimeOfDay(endTime),
      'room': room,
    };
  }

  static TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Schedule copyWith({
    int? id,
    int? groupSubjectId,
    int? day,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    String? room,
  }) {
    return Schedule(
      id: id ?? this.id,
      groupSubjectId: groupSubjectId ?? this.groupSubjectId,
      day: day ?? this.day,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
    );
  }
}