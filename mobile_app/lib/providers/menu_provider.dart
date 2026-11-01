import 'package:flutter/foundation.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  Set<String> _favoriteIds = {};

  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _isLoading = false;

  List<CategoryModel> get categories => _categories;
  List<ProductModel> get products => _products;
  String? get selectedCategoryId => _selectedCategoryId;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  Set<String> get favoriteIds => _favoriteIds;

  MenuProvider() {
    loadData();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final ids = await StorageService.loadFavorites();
    _favoriteIds = ids.toSet();
    notifyListeners();
  }

  void toggleFavorite(String productId) {
    if (_favoriteIds.contains(productId)) {
      _favoriteIds.remove(productId);
    } else {
      _favoriteIds.add(productId);
    }
    StorageService.saveFavorites(_favoriteIds.toList());
    notifyListeners();
  }

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final cats = await _apiService.getCategories();
      final prods = await _apiService.getProducts();

      _categories = cats;
      _products = prods;
    } catch (_) {
      // Handled via ApiService fallbacks
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<ProductModel> get filteredProducts {
    var list = _products;

    if (_selectedCategoryId != null && _selectedCategoryId!.isNotEmpty) {
      list = list.where((p) => p.categoryId == _selectedCategoryId).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      list = list.where((p) {
        return p.nameAr.toLowerCase().contains(query) ||
            p.nameEn.toLowerCase().contains(query) ||
            p.descriptionAr.toLowerCase().contains(query) ||
            p.descriptionEn.toLowerCase().contains(query);
      }).toList();
    }

    return list;
  }

  List<ProductModel> get featuredProducts =>
      _products.where((p) => p.isFeatured && p.isAvailable).toList();

  List<ProductModel> get bestSellerProducts =>
      _products.where((p) => p.isBestSeller && p.isAvailable).toList();

  List<ProductModel> get favoriteProducts =>
      _products.where((p) => _favoriteIds.contains(p.id)).toList();

  // --- Admin Product Actions ---
  void addProduct(ProductModel product) {
    _products.insert(0, product);
    notifyListeners();
  }

  void updateProduct(ProductModel updated) {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx != -1) {
      _products[idx] = updated;
      notifyListeners();
    }
  }

  void toggleProductAvailability(String productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _products[idx];
      _products[idx] = ProductModel(
        id: p.id,
        categoryId: p.categoryId,
        nameAr: p.nameAr,
        nameEn: p.nameEn,
        descriptionAr: p.descriptionAr,
        descriptionEn: p.descriptionEn,
        imageUrl: p.imageUrl,
        basePrice: p.basePrice,
        isAvailable: !p.isAvailable,
        isSampleRequiringAdminConfirmation: p.isSampleRequiringAdminConfirmation,
        preparationNotes: p.preparationNotes,
        isFeatured: p.isFeatured,
        isBestSeller: p.isBestSeller,
        sizes: p.sizes,
        extras: p.extras,
      );
      notifyListeners();
    }
  }

  void deleteProduct(String productId) {
    _products.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
