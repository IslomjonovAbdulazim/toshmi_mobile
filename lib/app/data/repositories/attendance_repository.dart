import '../../../core/base/base_repository.dart';
import '../models/attendance_model.dart';
import '../../utils/constants/api_constants.dart';

class AttendanceRepository extends BaseRepository {

  // Get attendance records for student
  Future<List<Attendance>> getAttendance() async {
    try {
      final response = await get(ApiConstants.studentAttendance);
      return parseList(response.body, Attendance.fromJson);
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  // Get attendance records for student by date range
  Future<List<Attendance>> getAttendanceByDateRange({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = buildQuery({
        'start_date': startDate,
        'end_date': endDate,
      });

      final response = await get(ApiConstants.studentAttendance, query: query);
      return parseList(response.body, Attendance.fromJson);
    } catch (e) {
      throw Exception('Failed to load attendance: $e');
    }
  }

  // Mark single attendance (teacher)
  Future<void> markAttendance({
    required int studentId,
    required int groupSubjectId,
    required DateTime date,
    required String status,
  }) async {
    try {
      await post(ApiConstants.teacherBulkAttendance, {
        'group_subject_id': groupSubjectId,
        'date': date.toIso8601String().split('T')[0],
        'records': [
          {
            'student_id': studentId,
            'status': status,
          }
        ],
      });
    } catch (e) {
      throw Exception('Failed to mark attendance: $e');
    }
  }

  // Bulk attendance marking (teacher)
  Future<void> bulkAttendance({
    required int groupSubjectId,
    required DateTime date,
    required Map<int, String> attendanceRecords,
  }) async {
    try {
      final records = attendanceRecords.entries.map((entry) => {
        'student_id': entry.key,
        'status': entry.value,
      }).toList();

      await post(ApiConstants.teacherBulkAttendance, {
        'group_subject_id': groupSubjectId,
        'date': date.toIso8601String().split('T')[0],
        'records': records,
      });
    } catch (e) {
      throw Exception('Failed to submit bulk attendance: $e');
    }
  }

  // Get attendance table for teacher
  Future<Map<String, dynamic>> getAttendanceTable({
    required int groupSubjectId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final query = buildQuery({
        'group_subject_id': groupSubjectId,
        'start_date': startDate,
        'end_date': endDate,
      });

      final response = await get(ApiConstants.teacherAttendanceTable, query: query);
      return response.body as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load attendance table: $e');
    }
  }

  // Get attendance summary for student
  Future<Map<String, dynamic>> getAttendanceSummary() async {
    try {
      final attendanceList = await getAttendance();

      final summary = <String, int>{
        'present': 0,
        'absent': 0,
        'late': 0,
        'excused': 0,
        'total': attendanceList.length,
      };

      for (final attendance in attendanceList) {
        summary[attendance.status] = (summary[attendance.status] ?? 0) + 1;
      }

      final presentPercentage = summary['total']! > 0
          ? (summary['present']! / summary['total']! * 100).toStringAsFixed(1)
          : '0.0';

      return {
        ...summary,
        'present_percentage': double.parse(presentPercentage),
      };
    } catch (e) {
      throw Exception('Failed to calculate attendance summary: $e');
    }
  }

  // Get attendance for parent (child)
  Future<List<Attendance>> getChildAttendance(int childId) async {
    try {
      final response = await get('${ApiConstants.parentChildren}/$childId/attendance');
      return parseList(response.body, Attendance.fromJson);
    } catch (e) {
      throw Exception('Failed to load child attendance: $e');
    }
  }

  @override
  void clearCache() {
    // Implement cache clearing if needed
  }
}