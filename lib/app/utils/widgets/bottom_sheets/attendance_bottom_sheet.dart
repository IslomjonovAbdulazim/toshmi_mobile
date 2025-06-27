import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';

class AttendanceBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> students;
  final DateTime date;
  final int groupSubjectId;

  const AttendanceBottomSheet({
    super.key,
    required this.students,
    required this.date,
    required this.groupSubjectId,
  });

  @override
  State<AttendanceBottomSheet> createState() => _AttendanceBottomSheetState();
}

class _AttendanceBottomSheetState extends State<AttendanceBottomSheet> {
  final Map<int, String> _attendanceRecords = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Davomat belgilash',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          Text(
            'Sana: ${widget.date.day}.${widget.date.month}.${widget.date.year}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: widget.students.length,
              itemBuilder: (context, index) {
                final student = widget.students[index];
                final studentId = student['student_id'] ?? student['id'];

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student['name'] ?? 'Unknown',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildStatusButton('present', 'Bor', AppColors.present, studentId),
                            const SizedBox(width: 8),
                            _buildStatusButton('absent', 'Yo\'q', AppColors.absent, studentId),
                            const SizedBox(width: 8),
                            _buildStatusButton('late', 'Kech', AppColors.late, studentId),
                            const SizedBox(width: 8),
                            _buildStatusButton('excused', 'Uzrli', AppColors.excused, studentId),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Bekor qilish'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _attendanceRecords.isNotEmpty ? _submitAttendance : null,
                  child: const Text('Saqlash'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(String status, String label, Color color, int studentId) {
    final isSelected = _attendanceRecords[studentId] == status;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _attendanceRecords[studentId] = status;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _submitAttendance() {
    Get.back(result: _attendanceRecords);
  }
}