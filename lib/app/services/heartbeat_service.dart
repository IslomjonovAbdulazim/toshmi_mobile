import 'dart:async';
import 'package:get/get.dart';
import '../data/repositories/auth_repository.dart';

class HeartbeatService extends GetxService {
  static HeartbeatService get to => Get.find();
  
  AuthRepository? _authRepository;
  Timer? _heartbeatTimer;
  
  final isRunning = false.obs;
  final lastHeartbeat = DateTime.now().obs;
  late DateTime _startTime;
  
  @override
  void onInit() {
    super.onInit();
    
    print('🔧 [HEARTBEAT] Service initialized');
    
    // Don't start automatically - wait for login
    // startHeartbeat();
  }
  
  @override
  void onClose() {
    stopHeartbeat();
    super.onClose();
  }
  
  void startHeartbeat() {
    if (_heartbeatTimer?.isActive == true) return;
    
    // Initialize auth repository if not already done
    try {
      _authRepository ??= Get.find<AuthRepository>();
      print('🔧 [HEARTBEAT] AuthRepository found successfully');
    } catch (e) {
      print('❌ [HEARTBEAT] AuthRepository not found: $e');
      return;
    }
    
    _startTime = DateTime.now();
    isRunning.value = true;
    
    final startTimeStr = '${_startTime.hour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')}:${_startTime.second.toString().padLeft(2, '0')}';
    print('🚀 [HEARTBEAT] Service started at $startTimeStr - calling every 5 seconds');
    
    // Call immediately first time
    _sendHeartbeat();
    
    // Then call every 5 seconds
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _sendHeartbeat();
    });
  }
  
  void stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    isRunning.value = false;
    
    final stopTime = DateTime.now();
    final stopTimeStr = '${stopTime.hour.toString().padLeft(2, '0')}:${stopTime.minute.toString().padLeft(2, '0')}:${stopTime.second.toString().padLeft(2, '0')}';
    print('⏹️ [HEARTBEAT] Service stopped at $stopTimeStr');
  }
  
  Future<void> _sendHeartbeat() async {
    if (_authRepository == null) {
      print('❌ [HEARTBEAT] AuthRepository is null - cannot send heartbeat');
      return;
    }
    
    try {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      
      print('💓 [HEARTBEAT] Sending heartbeat at $timeStr...');
      
      final response = await _authRepository!.post('/auth/heartbeat', {});
      lastHeartbeat.value = now;
      
      print('✅ [HEARTBEAT] Success at $timeStr - Status: ${response.statusCode}');
      
      // Log response data occasionally (every 30 seconds)
      final secondsSinceStart = now.difference(_startTime).inSeconds;
      if (secondsSinceStart % 30 == 0) {
        final responseData = response.body as Map<String, dynamic>?;
        print('📊 [HEARTBEAT] Response: ${responseData?['status']} - ${responseData?['timestamp']}');
      }
    } catch (e) {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
      
      print('❌ [HEARTBEAT] Failed at $timeStr - Error: $e');
      
      // Stop if auth fails
      if (e.toString().contains('401') || e.toString().contains('403')) {
        print('🔒 [HEARTBEAT] Auth error - stopping heartbeat service');
        stopHeartbeat();
      }
    }
  }
  
  // Manual heartbeat call
  Future<void> sendHeartbeatNow() async {
    await _sendHeartbeat();
  }
  
  // Restart heartbeat (useful after login/logout)
  void restartHeartbeat() {
    stopHeartbeat();
    startHeartbeat();
  }
}