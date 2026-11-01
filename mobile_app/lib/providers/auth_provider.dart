import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  bool _isAuthenticated = false;
  String? _adminToken;
  String _adminUsername = 'admin';
  bool _isLoading = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get adminToken => _adminToken;
  String get adminUsername => _adminUsername;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final token = await StorageService.getAdminToken();
    if (token != null && token.isNotEmpty) {
      _adminToken = token;
      _isAuthenticated = true;
      notifyListeners();
    }
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _apiService.adminLogin(username, password);
      if (token != null) {
        _adminToken = token;
        _adminUsername = username;
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (_) {}

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _adminToken = null;
    _isAuthenticated = false;
    await StorageService.setAdminToken(null);
    notifyListeners();
  }
}
