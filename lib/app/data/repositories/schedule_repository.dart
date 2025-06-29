import 'package:flutter/material.dart';
import '../../../core/base/base_repository.dart';
import '../models/schedule_model.dart';
import '../../utils/constants/api_constants.dart';
import '../../services/auth_service.dart';
import 'package:get/get.dart';

class ScheduleRepository extends BaseRepository {
  final AuthService _authService = Get.find<AuthService>();

  // Get schedule (role-based endpoint selection)
  Future<List<Schedule>> getSchedule() async {
    try {
      String endpoint;
      switch (_authService.userRole?.toLowerCase()) {
        case 'admin':
          endpoint = ApiConstants.adminSchedule;
          break;
        case 'student':
          endpoint = ApiConstants.studentSchedule;
          break;
        default:
          throw Exception('Invalid role for schedule access');
      }

      final response = await get(endpoint);
      return parseList(response.body, Schedule.fromJson);
    } catch (e) {
      throw Exception('Failed to load schedule: $e');
    }
  }

  // Create schedule (admin only)
  Future<Map<String, dynamic>> createSchedule({
    required int groupSubjectId,
    required int day, // 0-6 (Monday-Sunday)
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String room,
  }) async {
    try {
      final response = await post(ApiConstants.adminSchedule, {
        'group_subject_id': groupSubjectId,
        'day': day,
        'start_time': _formatTimeOfDay(startTime),
        'end_time': _formatTimeOfDay(endTime),
        'room': room,
      });

      // CRITICAL FIX: Return response data instead of calling non-existent endpoint
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to create schedule: $e');
    }
  }

  // Update schedule (admin only)
  Future<void> updateSchedule({
    required int scheduleId,
    required int groupSubjectId,
    required int day,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required String room,
  }) async {
    try {
      await put('${ApiConstants.adminSchedule}/$scheduleId', {
        'group_subject_id': groupSubjectId,
        'day': day,
        'start_time': _formatTimeOfDay(startTime),
        'end_time': _formatTimeOfDay(endTime),
        'room': room,
      });
    } catch (e) {
      throw Exception('Failed to update schedule: $e');
    }
  }

  // Delete schedule (admin only)
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await delete('${ApiConstants.adminSchedule}/$scheduleId');
    } catch (e) {
      throw Exception('Failed to delete schedule: $e');
    }
  }

  // CRITICAL FIX: Backend has no individual GET endpoint, find from cached list
  Future<Schedule?> findScheduleById(int scheduleId) async {
    try {
      final schedules = await getSchedule();
      return schedules.firstWhereOrNull((s) => s.id == scheduleId);
    } catch (e) {
      throw Exception('Failed to find schedule: $e');
    }
  }

  // Get schedule for specific day
  Future<List<Schedule>> getScheduleByDay(int day) async {
    try {
      final schedules = await getSchedule();
      return schedules.where((s) => s.day == day).toList()
        ..sort((a, b) => _compareTimeOfDay(a.startTime, b.startTime));
    } catch (e) {
      throw Exception('Failed to load schedule by day: $e');
    }
  }

  // Get today's schedule
  Future<List<Schedule>> getTodaySchedule() async {
    try {
      final today = DateTime.now().weekday - 1; // Convert to 0-6 format
      return await getScheduleByDay(today);
    } catch (e) {
      throw Exception('Failed to load today\'s schedule: $e');
    }
  }

  // Get weekly schedule organized by days
  Future<Map<int, List<Schedule>>> getWeeklySchedule() async {
    try {
      final schedules = await getSchedule();
      final weeklySchedule = <int, List<Schedule>>{};

      for (int day = 0; day < 7; day++) {
        weeklySchedule[day] = schedules
            .where((s) => s.day == day)
            .toList()
          ..sort((a, b) => _compareTimeOfDay(a.startTime, b.startTime));
      }

      return weeklySchedule;
    } catch (e) {
      throw Exception('Failed to load weekly schedule: $e');
    }
  }

  // Get next class
  Future<Schedule?> getNextClass() async {
    try {
      final todaySchedule = await getTodaySchedule();
      final now = TimeOfDay.now();

      for (final schedule in todaySchedule) {
        if (_compareTimeOfDay(schedule.startTime, now) > 0) {
          return schedule;
        }
      }

      // If no more classes today, find first class tomorrow
      final tomorrow = (DateTime.now().weekday) % 7;
      final tomorrowSchedule = await getScheduleByDay(tomorrow);
      return tomorrowSchedule.isNotEmpty ? tomorrowSchedule.first : null;
    } catch (e) {
      throw Exception('Failed to find next class: $e');
    }
  }

  // Get current class
  Future<Schedule?> getCurrentClass() async {
    try {
      final todaySchedule = await getTodaySchedule();
      final now = TimeOfDay.now();

      for (final schedule in todaySchedule) {
        if (_isTimeBetween(now, schedule.startTime, schedule.endTime)) {
          return schedule;
        }
      }

      return null;
    } catch (e) {
      throw Exception('Failed to find current class: $e');
    }
  }

  // Check for schedule conflicts
  Future<bool> hasConflict({
    required int groupSubjectId,
    required int day,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    int? excludeScheduleId,
  }) async {
    try {
      final schedules = await getSchedule();

      for (final schedule in schedules) {
        // Skip the schedule being edited
        if (excludeScheduleId != null && schedule.id == excludeScheduleId) {
          continue;
        }

        // Check same day
        if (schedule.day != day) continue;

        // Check time overlap
        if (_timesOverlap(startTime, endTime, schedule.startTime, schedule.endTime)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      throw Exception('Failed to check schedule conflicts: $e');
    }
  }

  // Get schedule by room
  Future<List<Schedule>> getScheduleByRoom(String room) async {
    try {
      final schedules = await getSchedule();
      return schedules
          .where((s) => s.room.toLowerCase() == room.toLowerCase())
          .toList();
    } catch (e) {
      throw Exception('Failed to load schedule by room: $e');
    }
  }

  // Get available rooms for time slot
  Future<List<String>> getAvailableRooms({
    required int day,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
  }) async {
    try {
      final schedules = await getSchedule();
      final allRooms = schedules.map((s) => s.room).toSet().toList();
      final busyRooms = <String>{};

      for (final schedule in schedules) {
        if (schedule.day == day &&
            _timesOverlap(startTime, endTime, schedule.startTime, schedule.endTime)) {
          busyRooms.add(schedule.room);
        }
      }

      return allRooms.where((room) => !busyRooms.contains(room)).toList();
    } catch (e) {
      throw Exception('Failed to find available rooms: $e');
    }
  }

  // CRITICAL FIX: Backend expects "HH:MM:SS" format
  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) return a.hour.compareTo(b.hour);
    return a.minute.compareTo(b.minute);
  }

  bool _isTimeBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    return _compareTimeOfDay(time, start) >= 0 && _compareTimeOfDay(time, end) <= 0;
  }

  bool _timesOverlap(TimeOfDay start1, TimeOfDay end1, TimeOfDay start2, TimeOfDay end2) {
    return _compareTimeOfDay(start1, end2) < 0 && _compareTimeOfDay(end1, start2) > 0;
  }

  @override
  void clearCache() {
    // Clear cached schedule data
  }
}