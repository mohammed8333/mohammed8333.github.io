import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pizza_awlad_alsheikh/core/constants/app_colors.dart';
import '../models/category.dart';

import '../providers/settings_provider.dart';

class CategoryChips extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedCategoryId;
  final ValueChanged<String?> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'local_pizza':
        return Icons.local_pizza;
      case 'lunch_dining':
        return Icons.lunch_dining;
      case 'fastfood':
        return Icons.fastfood;
      case 'dinner_dining':
        return Icons.dinner_dining;
      case 'pie_menu':
        return Icons.pie_chart_outline;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'local_drink':
        return Icons.local_drink;
      default:
        return Icons.restaurant_menu;
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isArabic = settings.isArabic;

    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length + 1, // +1 for "All / الكل"
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedCategoryId == null;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                selected: isSelected,
                avatar: Icon(
                  Icons.apps,
                  size: 18,
                  color: isSelected ? Colors.white : AppColors.primary,
                ),
                label: Text(
                  isArabic ? 'الكل' : 'All',
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : null,
                  ),
                ),
                selectedColor: AppColors.primary,
                backgroundColor: Theme.of(context).cardColor,
                onSelected: (_) => onCategorySelected(null),
              ),
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategoryId == category.id;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              selected: isSelected,
              avatar: Icon(
                _getCategoryIcon(category.icon),
                size: 18,
                color: isSelected ? Colors.white : AppColors.secondary,
              ),
              label: Text(
                isArabic ? category.nameAr : category.nameEn,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selectedColor: AppColors.primary,
              backgroundColor: Theme.of(context).cardColor,
              onSelected: (_) => onCategorySelected(category.id),
            ),
          );
        },
      ),
    );
  }
}
