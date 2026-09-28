import 'package:flutter/material.dart';
import 'app_colors.dart';

class CategoryItem {
  final String name;
  final IconData icon;
  final Color color;

  const CategoryItem({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CurrencyItem {
  final String code;
  final String symbol;
  final String name;

  const CurrencyItem({
    required this.code,
    required this.symbol,
    required this.name,
  });
}

class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String defaultCurrencySymbol = 'Rs.';
  static const String defaultCurrencyCode = 'PKR';

  // Firestore Collection Name
  static const String expensesCollection = 'expenses';

  // Supported Currency List
  static const List<CurrencyItem> supportedCurrencies = [
    CurrencyItem(code: 'PKR', symbol: 'Rs.', name: 'Rupee (Rs.)'),
    CurrencyItem(code: 'INR', symbol: '₹', name: 'Indian Rupee (₹)'),
    CurrencyItem(code: 'USD', symbol: '\$', name: 'US Dollar (\$)'),
    CurrencyItem(code: 'EUR', symbol: '€', name: 'Euro (€)'),
    CurrencyItem(code: 'GBP', symbol: '£', name: 'British Pound (£)'),
    CurrencyItem(code: 'AED', symbol: 'AED', name: 'UAE Dirham (AED)'),
    CurrencyItem(code: 'SAR', symbol: 'SAR', name: 'Saudi Riyal (SAR)'),
  ];

  // Category Definitions
  static const List<CategoryItem> categories = [
    CategoryItem(
      name: 'Food & Dining',
      icon: Icons.restaurant,
      color: AppColors.food,
    ),
    CategoryItem(
      name: 'Transport',
      icon: Icons.directions_car,
      color: AppColors.transport,
    ),
    CategoryItem(
      name: 'Bills & Utilities',
      icon: Icons.receipt_long,
      color: AppColors.bills,
    ),
    CategoryItem(
      name: 'Entertainment',
      icon: Icons.movie,
      color: AppColors.entertainment,
    ),
    CategoryItem(
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: AppColors.shopping,
    ),
    CategoryItem(
      name: 'Health & Fitness',
      icon: Icons.medical_services,
      color: AppColors.health,
    ),
    CategoryItem(
      name: 'Education',
      icon: Icons.school,
      color: AppColors.education,
    ),
    CategoryItem(
      name: 'Other',
      icon: Icons.category,
      color: AppColors.other,
    ),
  ];

  static CategoryItem getCategoryByName(String name) {
    return categories.firstWhere(
      (cat) => cat.name.toLowerCase() == name.toLowerCase(),
      orElse: () => const CategoryItem(
        name: 'Other',
        icon: Icons.category,
        color: AppColors.other,
      ),
    );
  }

  static IconData getCategoryIcon(String categoryName) {
    return getCategoryByName(categoryName).icon;
  }

  static Color getCategoryColor(String categoryName) {
    return getCategoryByName(categoryName).color;
  }
}
