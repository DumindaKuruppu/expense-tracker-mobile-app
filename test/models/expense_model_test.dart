import 'package:expense_tracker_mobile_app/models/expense_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseModel Unit Tests', () {
    final now = DateTime(2025, 10, 24, 14, 30);

    test('should correctly serialize to and from Map', () {
      final expense = ExpenseModel(
        id: 'test-123',
        title: 'Dinner at Restaurant',
        amount: 45.50,
        category: 'Food & Dining',
        date: now,
        note: 'Steak and drinks',
      );

      final map = expense.toMap();
      final fromMapExpense = ExpenseModel.fromMap(map, 'test-123');

      expect(fromMapExpense.id, equals('test-123'));
      expect(fromMapExpense.title, equals('Dinner at Restaurant'));
      expect(fromMapExpense.amount, equals(45.50));
      expect(fromMapExpense.category, equals('Food & Dining'));
      expect(fromMapExpense.note, equals('Steak and drinks'));
    });

    test('should format currency correctly', () {
      final expense = ExpenseModel(
        id: '1',
        title: 'Coffee',
        amount: 4.99,
        category: 'Food & Dining',
        date: now,
      );

      expect(expense.formattedAmount, equals('\$4.99'));
    });

    test('should format dates correctly', () {
      final expense = ExpenseModel(
        id: '1',
        title: 'Coffee',
        amount: 4.99,
        category: 'Food & Dining',
        date: DateTime(2025, 10, 24),
      );

      expect(expense.formattedDate, equals('Oct 24, 2025'));
      expect(expense.formattedShortDate, equals('Oct 24'));
    });

    test('copyWith should update fields correctly', () {
      final original = ExpenseModel(
        id: '1',
        title: 'Old Title',
        amount: 10.0,
        category: 'Other',
        date: now,
      );

      final updated = original.copyWith(
        title: 'New Title',
        amount: 25.0,
      );

      expect(updated.id, equals('1'));
      expect(updated.title, equals('New Title'));
      expect(updated.amount, equals(25.0));
      expect(updated.category, equals('Other'));
    });
  });
}
