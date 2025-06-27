import 'package:get/get.dart';

import '../../services/storage_service.dart';

class StorageProvider extends GetxService {
  final StorageService _storageService = Get.find<StorageService>();

  // String operations
  Future<void> writeString(String key, String value) async {
    await _storageService.saveString(key, value);
  }

  String? readString(String key) {
    return _storageService.getString(key);
  }

  // Boolean operations
  Future<void> writeBool(String key, bool value) async {
    await _storageService.saveBool(key, value);
  }

  bool readBool(String key, {bool defaultValue = false}) {
    return _storageService.getBool(key, defaultValue: defaultValue);
  }

  // Integer operations
  Future<void> writeInt(String key, int value) async {
    await _storageService.saveInt(key, value);
  }

  int readInt(String key, {int defaultValue = 0}) {
    return _storageService.getInt(key, defaultValue: defaultValue);
  }

  // Double operations
  Future<void> writeDouble(String key, double value) async {
    await _storageService.saveDouble(key, value);
  }

  double readDouble(String key, {double defaultValue = 0.0}) {
    return _storageService.getDouble(key, defaultValue: defaultValue);
  }

  // List operations
  Future<void> writeList(String key, List<String> value) async {
    await _storageService.saveList(key, value);
  }

  List<String> readList(String key) {
    return _storageService.getList(key);
  }

  // JSON operations
  Future<void> writeJson(String key, Map<String, dynamic> value) async {
    await _storageService.saveJson(key, value);
  }

  Map<String, dynamic>? readJson(String key) {
    return _storageService.getJson(key);
  }

  // Auth specific operations
  Future<void> saveToken(String token) async {
    await _storageService.saveToken(token);
  }

  String? getToken() {
    return _storageService.getToken();
  }

  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storageService.saveUserData(userData);
  }

  Map<String, dynamic>? getUserData() {
    return _storageService.getUserData();
  }

  Future<void> clearAuthData() async {
    await _storageService.clearAuthData();
  }

  // Settings operations
  Future<void> saveThemeMode(String themeMode) async {
    await _storageService.saveThemeMode(themeMode);
  }

  String getThemeMode() {
    return _storageService.getThemeMode();
  }

  Future<void> saveLanguage(String language) async {
    await _storageService.saveLanguage(language);
  }

  String getLanguage() {
    return _storageService.getLanguage();
  }

  // Utility operations
  Future<void> remove(String key) async {
    await _storageService.remove(key);
  }

  bool containsKey(String key) {
    return _storageService.containsKey(key);
  }

  Future<void> clearAll() async {
    await _storageService.clearAll();
  }

  Set<String> getAllKeys() {
    return _storageService.getAllKeys();
  }
}