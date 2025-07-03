import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';
import '../../../utils/widgets/common/loading_widget.dart';
import '../controllers/parent_controller.dart';

class ParentHomeworkView extends StatefulWidget {
  const ParentHomeworkView({super.key});

  @override
  State<ParentHomeworkView> createState() => _ParentHomeworkViewState();
}

class _ParentHomeworkViewState extends State<ParentHomeworkView> with SingleTickerProviderStateMixin {
  late int childId;
  late ParentController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentController>();

    final arguments = Get.arguments as Map<String, dynamic>?;
    childId = arguments?['childId'] ?? controller.selectedChildId.value ?? 0;

    if (childId == 0) {
      Get.back();
      Get.snackbar('error'.tr, 'child_not_selected'.tr);
      return;
    }

    if (controller.selectedChildId.value != childId) {
      controller.selectChild(childId);
    }
  }

  Future<List<Map<String, dynamic>>> _getSortedHomework() async {
    final homework = controller.currentChildHomework.cast<Map<String, dynamic>>();
    homework.sort((a, b) => DateTime.parse(b['due_date']).compareTo(DateTime.parse(a['due_date'])));
    return homework;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '${'homework'.tr} - ${controller.selectedChildName}',
        actions: [
          IconButton(
            onPressed: () => controller.refreshChildHomework(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshChildHomework(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: LoadingWidget());
          }

          final homework = controller.currentChildHomework.cast<Map<String, dynamic>>();

          if (homework.isEmpty) {
            return _buildEmptyState();
          }

          final sortedHomework = List<Map<String, dynamic>>.from(homework)
            ..sort((a, b) => DateTime.parse(b['due_date']).compareTo(DateTime.parse(a['due_date'])));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedHomework.length,
            itemBuilder: (context, index) => _buildHomeworkItem(sortedHomework[index]),
          );
        }),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('homework_empty'.tr, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600])),
            const SizedBox(height: 8),
            Text('homework_empty_subtitle'.tr, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeworkItem(Map<String, dynamic> homework) {
    final title = homework['title'] as String;
    final description = homework['description'] as String;
    final dueDate = DateTime.parse(homework['due_date']);
    final maxPoints = homework['max_points'] as int;
    final subject = homework['subject'] as String;
    final teacher = homework['teacher'] as String;
    final grade = homework['grade'] as Map<String, dynamic>?;
    final externalLinks = homework['external_links'] as List<dynamic>? ?? [];
    final documentIds = homework['document_ids'] as List<dynamic>? ?? [];

    final now = DateTime.now();
    final isOverdue = dueDate.isBefore(now) && grade == null;
    final isCompleted = grade != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.parentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      subject,
                      style: TextStyle(
                        color: AppColors.parentColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 12, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          'completed'.tr,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                else if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning, size: 12, color: Colors.red),
                        const SizedBox(width: 4),
                        Text(
                          'overdue'.tr,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            if (description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 12),

            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: isOverdue ? Colors.red : Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${'deadline'.tr}: ${_formatDate(dueDate)}',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: isOverdue ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
                const Spacer(),
                Icon(Icons.star_border, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '$maxPoints ${'points'.tr}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  '${'teacher'.tr}: $teacher',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            if (grade != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.grade, color: Colors.green, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${'grade'.tr}: ${grade['points']}/$maxPoints',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    if (grade['comment'] != null && grade['comment'].toString().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        '${'comment'.tr}: ${grade['comment']}',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            if (externalLinks.isNotEmpty || documentIds.isNotEmpty) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (externalLinks.isNotEmpty) ...[
                    Icon(Icons.link, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${externalLinks.length} ${'links'.tr}',
                      style: const TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ],
                  if (externalLinks.isNotEmpty && documentIds.isNotEmpty)
                    const SizedBox(width: 16),
                  if (documentIds.isNotEmpty) ...[
                    Icon(Icons.attach_file, size: 16, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text(
                      '${documentIds.length} ${'files'.tr}',
                      style: const TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'january'.tr, 'february'.tr, 'march'.tr, 'april'.tr, 'may'.tr, 'june'.tr,
      'july'.tr, 'august'.tr, 'september'.tr, 'october'.tr, 'november'.tr, 'december'.tr
    ];

    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'today'.tr;
    } else if (difference == 1) {
      return 'tomorrow'.tr;
    } else if (difference == -1) {
      return 'yesterday'.tr;
    } else {
      return '${date.day} ${months[date.month - 1]}';
    }
  }
}