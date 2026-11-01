import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../../providers/menu_provider.dart';
import '../../providers/settings_provider.dart';
import '../../widgets/category_chips.dart';
import '../../widgets/product_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _showFavoritesOnly = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final menu = Provider.of<MenuProvider>(context, listen: false);
    _searchController.text = menu.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menu = Provider.of<MenuProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    var products = _showFavoritesOnly ? menu.favoriteProducts : menu.filteredProducts;

    return Column(
      children: [
        // Search & Favorites Header
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
          color: Theme.of(context).cardColor,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: isArabic ? 'بحث في قائمة الطعام...' : 'Search menu items...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  menu.setSearchQuery('');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onChanged: (val) => menu.setSearchQuery(val),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Favorites Filter Toggle
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: _showFavoritesOnly ? AppColors.primary : null,
                      foregroundColor: _showFavoritesOnly ? Colors.white : AppColors.primary,
                    ),
                    icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
                    tooltip: isArabic ? 'المفضلة' : 'Favorites',
                    onPressed: () {
                      setState(() => _showFavoritesOnly = !_showFavoritesOnly);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Category Filter Bar
              CategoryChips(
                categories: menu.categories,
                selectedCategoryId: menu.selectedCategoryId,
                onCategorySelected: (catId) {
                  setState(() => _showFavoritesOnly = false);
                  menu.selectCategory(catId);
                },
              ),
            ],
          ),
        ),

        // Product Count / Active filter indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _showFavoritesOnly
                    ? (isArabic ? 'الأصناف المفضلة (${products.length})' : 'Favorite Items (${products.length})')
                    : (isArabic ? 'الأصناف المتاحة (${products.length})' : 'Available Items (${products.length})'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
              ),
              if (menu.selectedCategoryId != null || menu.searchQuery.isNotEmpty)
                TextButton(
                  onPressed: () {
                    menu.selectCategory(null);
                    menu.setSearchQuery('');
                    _searchController.clear();
                  },
                  child: Text(isArabic ? 'إعادة ضبط الكل' : 'Reset All'),
                ),
            ],
          ),
        ),

        // Products List
        Expanded(
          child: menu.isLoading
              ? const Center(child: CircularProgressIndicator())
              : products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _showFavoritesOnly ? Icons.favorite_border : Icons.search_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _showFavoritesOnly
                                ? (isArabic ? 'لم تقم بإضافة أي أصناف للمفضلة بعد' : 'No favorite items yet')
                                : (isArabic ? 'لا توجد نتائج تطابق بحثك' : 'No items match your search'),
                            style: const TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemBuilder: (context, index) {
                        return ProductCard(product: products[index]);
                      },
                    ),
        ),
      ],
    );
  }
}
