import 'package:expense_tracker_mobile_app/models/expense_model.dart';
import 'package:expense_tracker_mobile_app/providers/expense_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseProvider Unit Tests', () {
    late ExpenseProvider provider;

    setUp(() {
      provider = ExpenseProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    test('initial state should have default month set to current month', () {
      final now = DateTime.now();
      expect(provider.selectedMonth.year, equals(now.year));
      expect(provider.selectedMonth.month, equals(now.month));
      expect(provider.selectedCategory, isNull);
      expect(provider.searchQuery, isEmpty);
    });

    test('setting selected category should filter expenses correctly', () async {
      // Allow stream to emit mock items
      await Future.delayed(const Duration(milliseconds: 100));

      provider.setSelectedCategory('Transport');
      expect(provider.selectedCategory, equals('Transport'));

      final filtered = provider.filteredExpenses;
      for (var item in filtered) {
        expect(item.category.toLowerCase(), equals('transport'));
      }
    });

    test('toggling category selection on same category resets to null', () async {
      provider.setSelectedCategory('Transport');
      expect(provider.selectedCategory, equals('Transport'));

      provider.setSelectedCategory('Transport');
      expect(provider.selectedCategory, isNull);
    });

    test('search query filters expenses by title or note', () async {
      await Future.delayed(const Duration(milliseconds: 100));

      provider.setSearchQuery('grocery');
      final filtered = provider.filteredExpenses;

      expect(filtered.isNotEmpty, isTrue);
      expect(
        filtered.first.title.toLowerCase().contains('grocery') ||
            (filtered.first.note?.toLowerCase().contains('grocery') ?? false),
        isTrue,
      );
    });

    test('addExpense adds item successfully', () async {
      await Future.delayed(const Duration(milliseconds: 100));
      final initialCount = provider.allExpenses.length;

      final newExpense = ExpenseModel(
        id: '',
        title: 'New Test Expense',
        amount: 99.99,
        category: 'Shopping',
        date: DateTime.now(),
      );

      final result = await provider.addExpense(newExpense);
      expect(result, isTrue);

      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.allExpenses.length, equals(initialCount + 1));
    });
  });
}
