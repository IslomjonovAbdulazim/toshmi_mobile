// lib/app/modules/teacher/views/grading/widgets/grade_input_cell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GradeInputCell extends StatefulWidget {
  final Map<String, dynamic> student;
  final int maxPoints;
  final Function(int studentId, int? points, String comment)? onChanged;
  final bool isReadOnly;

  const GradeInputCell({
    super.key,
    required this.student,
    required this.maxPoints,
    this.onChanged,
    this.isReadOnly = false,
  });

  @override
  State<GradeInputCell> createState() => _GradeInputCellState();
}

class _GradeInputCellState extends State<GradeInputCell> {
  late TextEditingController _pointsController;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    final grade = widget.student['grade'] as Map<String, dynamic>? ?? {};
    _pointsController = TextEditingController(
      text: grade['points']?.toString() ?? '',
    );
    _commentController = TextEditingController(
      text: grade['comment'] ?? '',
    );
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grade = widget.student['grade'] as Map<String, dynamic>? ?? {};
    final hasGrade = grade['points'] != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: hasGrade
            ? theme.colorScheme.primaryContainer.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasGrade
              ? theme.colorScheme.primary.withOpacity(0.3)
              : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.student['name'] ?? 'Unknown',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (hasGrade)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Graded',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _pointsController,
                  enabled: !widget.isReadOnly,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'Points',
                    hintText: '0',
                    suffixText: '/${widget.maxPoints}',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => _onGradeChanged(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _commentController,
                  enabled: !widget.isReadOnly,
                  decoration: InputDecoration(
                    labelText: 'Comment',
                    hintText: 'Optional feedback',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => _onGradeChanged(),
                ),
              ),
            ],
          ),
          if (_pointsController.text.isNotEmpty &&
              (int.tryParse(_pointsController.text) ?? 0) > widget.maxPoints)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Points cannot exceed ${widget.maxPoints}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onGradeChanged() {
    final points = int.tryParse(_pointsController.text);
    widget.onChanged?.call(
      widget.student['student_id'],
      points,
      _commentController.text,
    );
  }
}