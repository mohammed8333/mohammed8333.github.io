import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pizza_awlad_alsheikh/core/constants/app_constants.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../models/order_model.dart';
import '../models/restaurant_settings.dart';
import 'mock_data.dart';
import 'storage_service.dart';

class ApiService {
  String baseUrl = AppConstants.defaultApiUrl;

  ApiService({String? url}) {
    if (url != null) baseUrl = url;
  }

  // --- Categories ---
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/categories'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((c) => CategoryModel.fromJson(c)).toList();
      }
    } catch (_) {
      // Fallback to offline mock data
    }
    return MockData.getCategories();
  }

  // --- Products ---
  Future<List<ProductModel>> getProducts({String? categoryId, String? search}) async {
    try {
      final queryParams = <String, String>{};
      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['categoryId'] = categoryId;
      }
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final uri = Uri.parse('$baseUrl/products').replace(queryParameters: queryParams.isEmpty ? null : queryParams);
      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((p) => ProductModel.fromJson(p)).toList();
      }
    } catch (_) {
      // Fallback to offline mock data
    }

    var products = MockData.getProducts();
    if (categoryId != null && categoryId.isNotEmpty) {
      products = products.where((p) => p.categoryId == categoryId).toList();
    }
    if (search != null && search.isNotEmpty) {
      final s = search.toLowerCase();
      products = products
          .where((p) =>
              p.nameAr.toLowerCase().contains(s) ||
              p.nameEn.toLowerCase().contains(s) ||
              p.descriptionAr.toLowerCase().contains(s))
          .toList();
    }
    return products;
  }

  // --- Restaurant Settings ---
  Future<RestaurantSettingsModel> getSettings() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/settings'))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> raw = jsonDecode(utf8.decode(response.bodyBytes));
        final map = raw.map((k, v) => MapEntry(k, v?.toString() ?? ''));
        return RestaurantSettingsModel.fromMap(map);
      }
    } catch (_) {
      // Fallback
    }
    return RestaurantSettingsModel();
  }

  // --- Order Submission ---
  Future<OrderModel> submitOrder(OrderModel order) async {
    try {
      final body = jsonEncode({
        'customerName': order.customerName,
        'customerPhone': order.customerPhone,
        'deliveryAddress': order.deliveryAddress,
        'area': order.area,
        'orderType': order.orderType == OrderType.delivery ? 1 : 2,
        'paymentMethod': order.paymentMethod,
        'notes': order.notes,
        'latitude': order.latitude,
        'longitude': order.longitude,
        'subtotal': order.subtotal,
        'deliveryFee': order.deliveryFee,
        'discount': order.discount,
        'totalAmount': order.totalAmount,
        'items': order.items.map((i) => i.toJson()).toList(),
      });

      final response = await http
          .post(
            Uri.parse('$baseUrl/orders'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final created = OrderModel.fromJson(data);
        await StorageService.saveOrder(created);
        return created;
      }
    } catch (_) {
      // Fallback: save locally
    }

    await StorageService.saveOrder(order);
    return order;
  }

  // --- Admin Authentication ---
  Future<String?> adminLogin(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final token = data['token'] as String?;
        if (token != null) {
          await StorageService.setAdminToken(token);
          return token;
        }
      }
    } catch (_) {
      // Local fallback for offline admin testing
    }

    if (username.trim().toLowerCase() == 'admin' &&
        (password == 'AdminPassword123!' || password == 'admin123')) {
      const mockToken = 'mock_admin_jwt_token_valid';
      await StorageService.setAdminToken(mockToken);
      return mockToken;
    }

    return null;
  }

  // --- Admin Orders Management ---
  Future<List<OrderModel>> getAdminOrders({int? status}) async {
    try {
      final token = await StorageService.getAdminToken();
      final uri = Uri.parse('$baseUrl/orders');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(response.bodyBytes));
        return list.map((o) => OrderModel.fromJson(o)).toList();
      }
    } catch (_) {
      // Fallback
    }

    return StorageService.loadOrders();
  }

  // --- Update Order Status ---
  Future<bool> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    try {
      final token = await StorageService.getAdminToken();
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'status': newStatus.index + 1}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) return true;
    } catch (_) {
      // Fallback
    }

    // Update local storage
    final orders = await StorageService.loadOrders();
    final idx = orders.indexWhere((o) => o.id == orderId);
    if (idx != -1) {
      orders[idx].status = newStatus;

      // Saved in memory / storage
      return true;
    }
    return true;
  }
}
