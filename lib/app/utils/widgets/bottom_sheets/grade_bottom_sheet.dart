import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../helpers/validation_helper.dart';
import '../common/custom_text_field.dart';

class GradeBottomSheet extends StatefulWidget {
  final Map<String, dynamic> assignment; // homework or exam info
  final Map<String, dynamic> student;
  final String type; // 'homework' or 'exam'
  final Map<String, dynamic>? existingGrade;

  const GradeBottomSheet({
    super.key,
    required this.assignment,
    required this.student,
    required this.type,
    this.existingGrade,
  });

  @override
  State<GradeBottomSheet> createState() => _GradeBottomSheetState();
}

class _GradeBottomSheetState extends State<GradeBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _pointsController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingGrade != null) {
      _pointsController.text = widget.existingGrade!['points'].toString();
      _commentController.text = widget.existingGrade!['comment'] ?? '';
    }
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxPoints = widget.assignment['max_points'] ?? 100;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ball berish',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Assignment info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignment['title'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Talaba: ${widget.student['name']}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Maksimal ball: $maxPoints',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Grade input
            CustomTextField(
              label: 'Ball (0-$maxPoints)',
              controller: _pointsController,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (ValidationHelper.required(value, fieldName: 'Ball') != null) {
                  return ValidationHelper.required(value, fieldName: 'Ball');
                }

                final points = int.tryParse(value!);
                if (points == null) {
                  return 'Ball raqam bo\'lishi kerak';
                }

                if (points < 0 || points > maxPoints) {
                  return 'Ball 0 dan $maxPoints gacha bo\'lishi kerak';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            // Comment input
            CustomTextField(
              label: 'Izoh (ixtiyoriy)',
              controller: _commentController,
              maxLines: 3,
              hint: 'O\'qituvchi izohi...',
            ),

            const SizedBox(height: 24),

            // Action buttons
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
                    onPressed: _submitGrade,
                    child: Text(widget.existingGrade != null ? 'Yangilash' : 'Saqlash'),
                  ),
                ),
              ],
            ),

            // Show percentage preview
            const SizedBox(height: 16),
            Obx(() => _buildPercentagePreview(maxPoints)),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentagePreview(int maxPoints) {
    final pointsText = _pointsController.text;
    if (pointsText.isEmpty) return const SizedBox.shrink();

    final points = int.tryParse(pointsText);
    if (points == null) return const SizedBox.shrink();

    final percentage = (points / maxPoints * 100).toStringAsFixed(1);
    Color percentageColor;
    String grade;

    if (points >= maxPoints * 0.9) {
      percentageColor = Colors.green;
      grade = 'A\'lo';
    } else if (points >= maxPoints * 0.75) {
      percentageColor = Colors.lightGreen;
      grade = 'Yaxshi';
    } else if (points >= maxPoints * 0.6) {
      percentageColor = Colors.orange;
      grade = 'Qoniqarli';
    } else {
      percentageColor = Colors.red;
      grade = 'Qoniqarsiz';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: percentageColor.withOpacity(0.1),
        border: Border.all(color: percentageColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Natija: $percentage% ($grade)',
            style: TextStyle(
              color: percentageColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(
            Icons.school,
            color: percentageColor,
          ),
        ],
      ),
    );
  }

  void _submitGrade() {
    if (_formKey.currentState?.validate() != true) return;

    final gradeData = {
      'student_id': widget.student['student_id'] ?? widget.student['id'],
      'points': int.parse(_pointsController.text),
      'comment': _commentController.text.trim(),
      'assignment_id': widget.assignment['id'],
      'type': widget.type,
    };

    Get.back(result: gradeData);
  }
}