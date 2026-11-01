import 'package:flutter/material.dart';
import '../models/restaurant_settings.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  String _language = 'ar';
  bool _isDarkMode = false;
  RestaurantSettingsModel _settings = RestaurantSettingsModel();

  String get language => _language;
  bool get isDarkMode => _isDarkMode;
  bool get isArabic => _language == 'ar';
  RestaurantSettingsModel get settings => _settings;

  SettingsProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    _language = await StorageService.getLanguage();
    _isDarkMode = await StorageService.isDarkMode();
    notifyListeners();

    try {
      _settings = await _apiService.getSettings();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> toggleLanguage() async {
    _language = _language == 'ar' ? 'en' : 'ar';
    await StorageService.setLanguage(_language);
    notifyListeners();
  }

  Future<void> setLanguage(String lang) async {
    _language = lang;
    await StorageService.setLanguage(lang);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await StorageService.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  void updateSettings(RestaurantSettingsModel newSettings) {
    _settings = newSettings;
    notifyListeners();
  }
}
