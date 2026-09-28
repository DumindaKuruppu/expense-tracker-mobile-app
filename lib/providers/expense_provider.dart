import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';
import '../models/expense_model.dart';
import '../services/firestore_service.dart';

class ExpenseProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<List<ExpenseModel>>? _subscription;

  List<ExpenseModel> _allExpenses = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Currency Settings (Default: Rs. PKR)
  String _currencySymbol = AppConstants.defaultCurrencySymbol;
  String _currencyCode = AppConstants.defaultCurrencyCode;

  // Filter States
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  String? _selectedCategory; // null = "All"
  String _searchQuery = '';
  DateTimeRange? _customDateRange;

  ExpenseProvider({FirestoreService? firestoreService, String? userId})
      : _firestoreService = firestoreService ?? FirestoreService(userId: userId) {
    _subscribeToExpenses();
  }

  // Getters
  List<ExpenseModel> get allExpenses => _allExpenses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime get selectedMonth => _selectedMonth;
  String? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  DateTimeRange? get customDateRange => _customDateRange;

  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;

  /// Update active currency symbol and currency code.
  void setCurrency(String symbol, String code) {
    _currencySymbol = symbol;
    _currencyCode = code;
    notifyListeners();
  }

  /// Helper to format currency amount with active symbol.
  String formatAmount(double amount) {
    final sym = _currencySymbol;
    final symbolWithSpace = (sym.endsWith('.') || sym.length >= 3) ? '$sym ' : sym;
    final formatter = NumberFormat.currency(
      symbol: symbolWithSpace,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Update the active user ID for user-scoped expenses data.
  void updateUser(String? userId) {
    _firestoreService.setUserId(userId);
    _subscribeToExpenses();
  }

  void _subscribeToExpenses() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _firestoreService.getExpensesStream().listen(
      (expenses) {
        _allExpenses = expenses;
        _isLoading = false;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Failed to load expenses: ${error.toString()}';
        notifyListeners();
      },
    );
  }

  /// Get expenses filtered by selected month/date range, category, and search query.
  List<ExpenseModel> get filteredExpenses {
    return _allExpenses.where((expense) {
      // 1. Date Range / Month Filter
      bool matchesDate = true;
      if (_customDateRange != null) {
        final expDate = DateTime(
          expense.date.year,
          expense.date.month,
          expense.date.day,
        );
        final start = DateTime(
          _customDateRange!.start.year,
          _customDateRange!.start.month,
          _customDateRange!.start.day,
        );
        final end = DateTime(
          _customDateRange!.end.year,
          _customDateRange!.end.month,
          _customDateRange!.end.day,
          23,
          59,
          59,
        );
        matchesDate = expDate.isAfter(start.subtract(const Duration(seconds: 1))) &&
            expDate.isBefore(end);
      } else {
        matchesDate = expense.date.year == _selectedMonth.year &&
            expense.date.month == _selectedMonth.month;
      }

      // 2. Category Filter
      bool matchesCategory = true;
      if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
        matchesCategory =
            expense.category.toLowerCase() == _selectedCategory!.toLowerCase();
      }

      // 3. Search Query
      bool matchesSearch = true;
      if (_searchQuery.trim().isNotEmpty) {
        final query = _searchQuery.trim().toLowerCase();
        final titleMatch = expense.title.toLowerCase().contains(query);
        final noteMatch =
            expense.note?.toLowerCase().contains(query) ?? false;
        final categoryMatch =
            expense.category.toLowerCase().contains(query);
        matchesSearch = titleMatch || noteMatch || categoryMatch;
      }

      return matchesDate && matchesCategory && matchesSearch;
    }).toList();
  }

  /// Total expenses for the currently selected month.
  double get monthlyTotal {
    return _allExpenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Total expenses for the previous month.
  double get previousMonthTotal {
    final prevMonthDate = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    return _allExpenses
        .where((e) =>
            e.date.year == prevMonthDate.year &&
            e.date.month == prevMonthDate.month)
        .fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Month over month percentage change (+12.5% or -5.0%). Returns null if prev total is 0.
  double? get monthOverMonthPercentage {
    final prev = previousMonthTotal;
    if (prev <= 0) return null;
    final curr = monthlyTotal;
    return ((curr - prev) / prev) * 100;
  }

  /// Category spending map for current selected month (e.g., {'Food & Dining': 120.0, 'Transport': 45.0})
  Map<String, double> get categoryTotalsForSelectedMonth {
    final Map<String, double> map = {};
    for (var expense in _allExpenses) {
      if (expense.date.year == _selectedMonth.year &&
          expense.date.month == _selectedMonth.month) {
        map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
      }
    }
    return map;
  }

  /// Total number of transactions in the selected month
  int get selectedMonthTransactionCount {
    return _allExpenses
        .where((e) =>
            e.date.year == _selectedMonth.year &&
            e.date.month == _selectedMonth.month)
        .length;
  }

  // Filter Controls
  void setSelectedMonth(DateTime month) {
    _selectedMonth = DateTime(month.year, month.month);
    _customDateRange = null; // Clear custom range when month is selected
    notifyListeners();
  }

  void previousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    _customDateRange = null;
    notifyListeners();
  }

  void nextMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    _customDateRange = null;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off if selected again
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCustomDateRange(DateTimeRange? range) {
    _customDateRange = range;
    notifyListeners();
  }

  void resetFilters() {
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedCategory = null;
    _searchQuery = '';
    _customDateRange = null;
    notifyListeners();
  }

  // CRUD Methods
  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.addExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      await _firestoreService.updateExpense(expense);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update expense: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String id) async {
    try {
      await _firestoreService.deleteExpense(id);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete expense: $e';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
