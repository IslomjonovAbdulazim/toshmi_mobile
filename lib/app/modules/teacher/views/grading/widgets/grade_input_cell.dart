import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class GradeInputCell extends StatefulWidget {
  final int? initialPoints;
  final String initialComment;
  final int maxPoints;
  final Function(int? points, String comment) onChanged;

  const GradeInputCell({
    super.key,
    this.initialPoints,
    this.initialComment = '',
    required this.maxPoints,
    required this.onChanged,
  });

  @override
  State<GradeInputCell> createState() => _GradeInputCellState();
}

class _GradeInputCellState extends State<GradeInputCell> {
  late TextEditingController _pointsController;
  late TextEditingController _commentController;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(
      text: widget.initialPoints?.toString() ?? '',
    );
    _commentController = TextEditingController(
      text: widget.initialComment,
    );
  }

  @override
  void dispose() {
    _pointsController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _validateAndUpdate() {
    final pointsText = _pointsController.text.trim();
    int? points;
    bool hasError = false;

    if (pointsText.isNotEmpty) {
      points = int.tryParse(pointsText);
      if (points == null || points < 0 || points > widget.maxPoints) {
        hasError = true;
      }
    }

    setState(() {
      _hasError = hasError;
    });

    if (!hasError) {
      widget.onChanged(points, _commentController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _hasError
              ? theme.colorScheme.error
              : theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _pointsController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    labelText: 'grade_points'.tr,
                    hintText: '0-${widget.maxPoints}',
                    errorText: _hasError ? 'invalid_points'.tr : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (_) => _validateAndUpdate(),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '/${widget.maxPoints}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _commentController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'comment_optional'.tr,
              hintText: 'enter_comment'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (_) => _validateAndUpdate(),
          ),
        ],
      ),
    );
  }
}