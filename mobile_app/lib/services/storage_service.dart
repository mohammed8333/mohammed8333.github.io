import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';
import '../models/order_model.dart';

class StorageService {
  static const String _keyCart = 'pizza_cart_items';
  static const String _keyOrders = 'pizza_saved_orders';
  static const String _keyLang = 'pizza_app_language';
  static const String _keyDarkMode = 'pizza_app_dark_mode';
  static const String _keyToken = 'pizza_admin_jwt_token';
  static const String _keyFavorites = 'pizza_favorites_ids';

  // --- Cart Persistence ---
  static Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((i) => i.toJson()).toList();
    await prefs.setString(_keyCart, jsonEncode(jsonList));
  }

  static Future<List<CartItem>> loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyCart);
      if (str == null || str.isEmpty) return [];
      final List raw = jsonDecode(str);
      return raw.map((item) => CartItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyCart);
  }

  // --- Orders Persistence ---
  static Future<void> saveOrder(OrderModel order) async {
    final prefs = await SharedPreferences.getInstance();
    final orders = await loadOrders();
    orders.insert(0, order);
    final jsonList = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_keyOrders, jsonEncode(jsonList));
  }

  static Future<List<OrderModel>> loadOrders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_keyOrders);
      if (str == null || str.isEmpty) return [];
      final List raw = jsonDecode(str);
      return raw.map((item) => OrderModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  // --- Favorites Persistence ---
  static Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  static Future<void> saveFavorites(List<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyFavorites, ids);
  }

  // --- Settings Persistence ---
  static Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLang) ?? 'ar';
  }

  static Future<void> setLanguage(String lang) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, lang);
  }

  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
  }

  // --- Admin Token ---
  static Future<String?> getAdminToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  static Future<void> setAdminToken(String? token) async {
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_keyToken);
    } else {
      await prefs.setString(_keyToken, token);
    }
  }
}
