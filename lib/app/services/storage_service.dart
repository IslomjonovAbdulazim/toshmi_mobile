import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  // Storage keys
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language';
  static const String _biometricKey = 'biometric_enabled';
  static const String _notificationKey = 'notifications_enabled';

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth token methods
  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<void> removeToken() async {
    await _prefs.remove(_tokenKey);
  }

  // User data methods
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs.setString(_userDataKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final data = _prefs.getString(_userDataKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs.remove(_userDataKey);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await removeToken();
    await removeUserData();
  }

  // Theme mode
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs.setString(_themeKey, themeMode);
  }

  String getThemeMode() {
    return _prefs.getString(_themeKey) ?? 'system';
  }

  // Language
  Future<void> saveLanguage(String language) async {
    await _prefs.setString(_languageKey, language);
  }

  String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'en';
  }

  // Biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    await _prefs.setBool(_biometricKey, enabled);
  }

  bool getBiometricEnabled() {
    return _prefs.getBool(_biometricKey) ?? false;
  }

  // Notifications
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationKey, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs.getBool(_notificationKey) ?? true;
  }

  // Generic methods
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> saveDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> saveList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String> getList(String key) {
    return _prefs.getStringList(key) ?? [];
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    await _prefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final data = _prefs.getString(key);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  // Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  // Clear all storage
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Get all keys
  Set<String> getAllKeys() {
    return _prefs.getKeys();
  }
}