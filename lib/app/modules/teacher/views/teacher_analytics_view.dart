// lib/app/modules/teacher/views/teacher_analytics_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacher_home_controller.dart';
import '../../../utils/constants/app_colors.dart';

class TeacherAnalyticsView extends GetView<TeacherHomeController> {
  const TeacherAnalyticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Tahlil va hisobotlar',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download, color: Colors.white),
            onPressed: _exportReport,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadDashboardData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTimePeriodSelector(),
              const SizedBox(height: 16),
              _buildOverviewCards(),
              const SizedBox(height: 24),
              _buildPerformanceChart(),
              const SizedBox(height: 24),
              _buildGradingInsights(),
              const SizedBox(height: 24),
              _buildAttendanceOverview(),
              const SizedBox(height: 24),
              _buildSubjectBreakdown(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTimePeriodSelector() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.date_range, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Vaqt oralig\'i:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  _buildPeriodChip('Hafta', true),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Oy', false),
                  const SizedBox(width: 8),
                  _buildPeriodChip('Semestr', false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodChip(String label, bool isSelected) {
    return InkWell(
      onTap: () => _selectPeriod(label),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Umumiy ko\'rsatkichlar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Uy vazifalar',
                '${controller.totalHomework.value}',
                '+3 bu hafta',
                Icons.assignment,
                AppColors.success,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Imtihonlar',
                '${controller.totalExams.value}',
                '1 rejalashtirilgan',
                Icons.quiz,
                AppColors.warning,
                false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Baholangan',
                '87',
                '12 kutilmoqda',
                Icons.grade,
                AppColors.info,
                true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                'Davomat',
                '92%',
                '+2% dan o\'tgan oy',
                Icons.people,
                AppColors.primary,
                true,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
      String title,
      String value,
      String subtitle,
      IconData icon,
      Color color,
      bool isPositive,
      ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const Spacer(),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? AppColors.success : AppColors.error,
                  size: 16,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isPositive ? AppColors.success : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Talabalar samaradorligi',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              child: _buildSimpleChart(),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildChartLegend('A\'lo', AppColors.success),
                _buildChartLegend('Yaxshi', AppColors.info),
                _buildChartLegend('Qoniqarli', AppColors.warning),
                _buildChartLegend('Qoniqarsiz', AppColors.error),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleChart() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildChartBar('Dush', 0.8, AppColors.success),
        _buildChartBar('Sesh', 0.6, AppColors.info),
        _buildChartBar('Chor', 0.9, AppColors.success),
        _buildChartBar('Pay', 0.7, AppColors.warning),
        _buildChartBar('Jum', 0.5, AppColors.error),
        _buildChartBar('Shan', 0.3, AppColors.error),
        _buildChartBar('Yak', 0.8, AppColors.success),
      ],
    );
  }

  Widget _buildChartBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 150 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildGradingInsights() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Baholash tahlili',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'O\'rtacha ball',
                    '84.5',
                    Icons.trending_up,
                    AppColors.success,
                    '+2.3 dan o\'tgan oy',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    'Eng yuqori ball',
                    '98',
                    Icons.star,
                    AppColors.warning,
                    'Matematika',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInsightItem(
                    'Baholash tezligi',
                    '1.2 kun',
                    Icons.speed,
                    AppColors.info,
                    'O\'rtacha vaqt',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInsightItem(
                    'Qayta topshirish',
                    '8%',
                    Icons.refresh,
                    AppColors.error,
                    '3 ta vazifa',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightItem(
      String title,
      String value,
      IconData icon,
      Color color,
      String subtitle,
      ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceOverview() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.how_to_reg, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Davomat hisoboti',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildAttendanceCircle(
                    'Umumiy davomat',
                    0.92,
                    '92%',
                    AppColors.success,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAttendanceDetail('Bor', '156 ta', AppColors.success),
                      _buildAttendanceDetail('Yo\'q', '8 ta', AppColors.error),
                      _buildAttendanceDetail('Kech', '4 ta', AppColors.warning),
                      _buildAttendanceDetail('Uzrli', '2 ta', AppColors.info),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCircle(
      String title,
      double progress,
      String percentage,
      Color color,
      ) {
    return Column(
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Stack(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
              ),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.2),
                  ),
                  child: Center(
                    child: Text(
                      percentage,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAttendanceDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectBreakdown() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.subject, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Fanlar bo\'yicha tahlil',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSubjectItem('Matematika', 85.4, 45, AppColors.success),
            _buildSubjectItem('Fizika', 78.2, 38, AppColors.info),
            _buildSubjectItem('Kimyo', 82.1, 42, AppColors.warning),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectItem(String subject, double average, int students, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$students ta talaba',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${average.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'So\'nggi faollik',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              'Matematika uy vazifasi baholandi',
              '2 soat oldin',
              Icons.grade,
              AppColors.success,
            ),
            _buildActivityItem(
              'Fizika imtihoni yaratildi',
              '5 soat oldin',
              Icons.quiz,
              AppColors.info,
            ),
            _buildActivityItem(
              'Kimyo darsi davomati olindi',
              '1 kun oldin',
              Icons.how_to_reg,
              AppColors.warning,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(
      String title,
      String time,
      IconData icon,
      Color color,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _selectPeriod(String period) {
    Get.snackbar(
      'Vaqt oralig\'i',
      '$period tanlandi',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 1),
    );
  }

  void _exportReport() {
    Get.snackbar(
      'Eksport',
      'Hisobot PDF formatda yuklab olinmoqda...',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }
}