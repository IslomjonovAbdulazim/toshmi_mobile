// lib/app/data/repositories/group_subject_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/storage_service.dart';
import '../../utils/constants/api_constants.dart';
import '../models/group_subject_model.dart';

class GroupSubjectRepository {
  // Use Get.find to get the already initialized StorageService
  StorageService get _storageService => Get.find<StorageService>();

  // Get authorization headers
  Future<Map<String, String>> _getHeaders() async {
    final token = await _storageService.getToken();
    print('🔑 Token: ${token?.substring(0, 20)}...'); // Debug token (first 20 chars)
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get all group-subjects assigned to the current teacher
  /// Returns list of classes that teacher teaches
  Future<List<GroupSubject>> getTeacherGroupSubjects() async {
    try {
      print('🔄 GroupSubjectRepository: Getting teacher group subjects...');
      final headers = await _getHeaders();
      print('🔄 Headers: $headers');

      final url = ApiConstants.baseUrl + ApiConstants.teacherGroupSubjects;
      print('🔄 URL: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        print('✅ Parsed ${jsonList.length} group subjects');
        return jsonList.map((json) => GroupSubject.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied: Teacher permissions required');
      } else {
        throw Exception('Failed to load group subjects: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ GroupSubjectRepository error: $e');
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }

  /// Get schedule (times) for a specific group-subject
  /// Used for attendance - teacher selects class, then selects time
  Future<List<TeacherSchedule>> getGroupSubjectSchedule(int groupSubjectId) async {
    try {
      final headers = await _getHeaders();
      final url = ApiConstants.baseUrl +
          ApiConstants.teacherGroupSubjectSchedule +
          '/$groupSubjectId/schedule';

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => TeacherSchedule.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 403) {
        throw Exception('Access denied: Teacher permissions required');
      } else if (response.statusCode == 404) {
        throw Exception('Group-subject not found or not assigned to you');
      } else {
        throw Exception('Failed to load schedule: ${response.statusCode}');
      }
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        throw Exception('Network error: Please check your internet connection');
      }
      rethrow;
    }
  }

  /// Get formatted group-subject display name
  /// Helper method for UI display
  String getGroupSubjectDisplayName(GroupSubject groupSubject) {
    return '${groupSubject.subjectName} - ${groupSubject.groupName}';
  }

  /// Get formatted schedule display name
  /// Helper method for UI display
  String getScheduleDisplayName(TeacherSchedule schedule) {
    return '${schedule.dayName} ${schedule.timeRange}';
  }

  /// Filter schedules by day
  /// Helper method to group schedules by day of week
  Map<String, List<TeacherSchedule>> groupSchedulesByDay(List<TeacherSchedule> schedules) {
    final Map<String, List<TeacherSchedule>> grouped = {};

    for (final schedule in schedules) {
      if (!grouped.containsKey(schedule.dayName)) {
        grouped[schedule.dayName] = [];
      }
      grouped[schedule.dayName]!.add(schedule);
    }

    // Sort schedules within each day by start time
    grouped.forEach((day, scheduleList) {
      scheduleList.sort((a, b) => a.startTime.compareTo(b.startTime));
    });

    return grouped;
  }

  /// Get today's schedules for a group-subject
  /// Helper method to show only today's classes
  List<TeacherSchedule> getTodaySchedules(List<TeacherSchedule> schedules) {
    final today = DateTime.now().weekday; // 1 = Monday, 7 = Sunday
    final todayBackendFormat = today == 7 ? 0 : today; // Convert to backend format (0 = Sunday)

    return schedules.where((schedule) => schedule.day == todayBackendFormat).toList();
  }

  /// Check if schedule is currently active
  /// Helper method to highlight current class
  bool isScheduleActive(TeacherSchedule schedule) {
    final now = DateTime.now();
    final today = now.weekday == 7 ? 0 : now.weekday; // Convert to backend format

    if (schedule.day != today) return false;

    final currentTime = TimeOfDay.fromDateTime(now);
    final startTime = _parseTimeString(schedule.startTime);
    final endTime = _parseTimeString(schedule.endTime);

    return _isTimeInRange(currentTime, startTime, endTime);
  }

  /// Find group subject by ID from list
  GroupSubject? findGroupSubjectById(List<GroupSubject> groupSubjects, int id) {
    try {
      return groupSubjects.firstWhere((gs) => gs.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private helper methods
  TimeOfDay _parseTimeString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  bool _isTimeInRange(TimeOfDay current, TimeOfDay start, TimeOfDay end) {
    final currentMinutes = current.hour * 60 + current.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return currentMinutes >= startMinutes && currentMinutes <= endMinutes;
  }
}