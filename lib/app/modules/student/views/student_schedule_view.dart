// lib/app/modules/student/views/student_schedule_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/student_repository.dart';
import '../../../utils/widgets/common/custom_app_bar.dart';

class StudentScheduleView extends StatefulWidget {
  const StudentScheduleView({super.key});

  @override
  State<StudentScheduleView> createState() => _StudentScheduleViewState();
}

class _StudentScheduleViewState extends State<StudentScheduleView> {
  final StudentRepository repository = StudentRepository();
  final isLoading = false.obs;
  final schedule = <dynamic>[].obs;
  final selectedDay = (DateTime.now().weekday - 1).obs; // 0=Monday

  final days = ['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba'];

  @override
  void initState() {
    super.initState();
    loadSchedule();
  }

  Future<void> loadSchedule() async {
    try {
      isLoading.value = true;
      final data = await repository.getSchedule();
      schedule.value = data;
    } catch (e) {
      Get.snackbar('Xato', 'Dars jadvalini yuklashda xato: $e');
    } finally {
      isLoading.value = false;
    }
  }

  List<dynamic> get todaySchedule {
    return schedule.where((s) => s['day'] == selectedDay.value).toList()
      ..sort((a, b) => a['start_time'].compareTo(b['start_time']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dars jadvali',
        showBackButton: true,
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: Obx(() {
              if (isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return RefreshIndicator(
                onRefresh: loadSchedule,
                child: todaySchedule.isEmpty
                    ? _buildEmptyState()
                    : _buildScheduleList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = selectedDay.value == index;
            final today = DateTime.now().weekday - 1; // 0=Monday
            final isToday = today == index && today < 6; // Exclude Sunday

            return GestureDetector(
              onTap: () => selectedDay.value = index,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : (isToday ? Colors.blue.withOpacity(0.1) : null),
                  borderRadius: BorderRadius.circular(25),
                  border: isToday && !isSelected ? Border.all(color: Colors.blue) : null,
                ),
                child: Center(
                  child: Text(
                    days[index].substring(0, 3),
                    style: TextStyle(
                      color: isSelected ? Colors.white : (isToday ? Colors.blue : Theme.of(context).colorScheme.onSurface),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildScheduleList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: todaySchedule.length,
      itemBuilder: (context, index) => _buildScheduleCard(todaySchedule[index], index),
    );
  }

  Widget _buildScheduleCard(Map<String, dynamic> lesson, int index) {
    final startTime = lesson['start_time'] as String;
    final endTime = lesson['end_time'] as String;
    final isCurrentLesson = _isCurrentLesson(startTime, endTime);
    final s = startTime.split(":").take(2).join(":");
    final e = endTime.split(":").take(2).join(":");

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isCurrentLesson ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isCurrentLesson ? Border.all(color: Colors.green, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 60,
                decoration: BoxDecoration(
                  color: isCurrentLesson ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${index + 1}-dars',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isCurrentLesson) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Hozir',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson['subject'] ?? '',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson['teacher'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '$s - $e',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.room, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          lesson['room'] ?? '',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '${days[selectedDay.value]} kuni darslar yo\'q',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  bool _isCurrentLesson(String startTime, String endTime) {
    final now = TimeOfDay.now();
    final start = _parseTime(startTime);
    final end = _parseTime(endTime);

    final nowMinutes = now.hour * 60 + now.minute;
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;

    return nowMinutes >= startMinutes && nowMinutes <= endMinutes &&
        selectedDay.value == DateTime.now().weekday - 1;
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }
}