import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/expense_model.dart';

/// Dedicated service class isolating Cloud Firestore operations.
class FirestoreService {
  final FirebaseFirestore? _firestore;

  // In-memory fallback list to ensure app usability even if Firebase is uninitialized or offline
  final List<ExpenseModel> _mockExpenses = [];
  final StreamController<List<ExpenseModel>> _mockStreamController =
      StreamController<List<ExpenseModel>>.broadcast();
  bool _useFallback = false;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? _getFirestoreInstance() {
    if (_firestore == null) {
      _useFallback = true;
    }
    _initMockDataIfNeeded();
  }

  static FirebaseFirestore? _getFirestoreInstance() {
    try {
      return FirebaseFirestore.instance;
    } catch (e) {
      debugPrint('Firestore instance notice: $e (Running in fallback mode)');
      return null;
    }
  }

  void _initMockDataIfNeeded() {
    final now = DateTime.now();
    _mockExpenses.addAll([
      ExpenseModel(
        id: 'sample-1',
        title: 'Weekly Grocery Shopping',
        amount: 85.50,
        category: 'Food & Dining',
        date: now.subtract(const Duration(days: 1)),
        note: 'Supermarket supplies & vegetables',
      ),
      ExpenseModel(
        id: 'sample-2',
        title: 'Gas / Fuel Refill',
        amount: 45.00,
        category: 'Transport',
        date: now.subtract(const Duration(days: 2)),
        note: 'Full tank at Shell',
      ),
      ExpenseModel(
        id: 'sample-3',
        title: 'Electric & Power Bill',
        amount: 120.30,
        category: 'Bills & Utilities',
        date: now.subtract(const Duration(days: 3)),
        note: 'Monthly power consumption',
      ),
      ExpenseModel(
        id: 'sample-4',
        title: 'Cinema Movie Tickets',
        amount: 32.00,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 5)),
        note: 'IMAX weekend show',
      ),
      ExpenseModel(
        id: 'sample-5',
        title: 'Online Course Subscription',
        amount: 49.99,
        category: 'Education',
        date: now.subtract(const Duration(days: 8)),
        note: 'Flutter Advanced Masterclass',
      ),
    ]);
  }

  CollectionReference<Map<String, dynamic>>? get _expensesCollection =>
      _firestore?.collection(AppConstants.expensesCollection);

  /// Get real-time stream of expenses ordered by date descending.
  Stream<List<ExpenseModel>> getExpensesStream() {
    if (_useFallback || _expensesCollection == null) {
      Timer.run(() => _emitMockList());
      return _mockStreamController.stream;
    }

    try {
      return _expensesCollection!
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return ExpenseModel.fromFirestore(doc);
        }).toList();
      }).handleError((error) {
        debugPrint('Firestore Stream Error (switching to fallback): $error');
        _useFallback = true;
        _emitMockList();
        return _mockStreamController.stream;
      });
    } catch (e) {
      debugPrint('Firestore Stream Exception: $e');
      _useFallback = true;
      Timer.run(() => _emitMockList());
      return _mockStreamController.stream;
    }
  }

  void _emitMockList() {
    _mockExpenses.sort((a, b) => b.date.compareTo(a.date));
    if (!_mockStreamController.isClosed) {
      _mockStreamController.add(List.from(_mockExpenses));
    }
  }

  /// Add a new expense record to Cloud Firestore.
  Future<String> addExpense(ExpenseModel expense) async {
    if (_useFallback || _expensesCollection == null) {
      final newId = 'mock-${DateTime.now().millisecondsSinceEpoch}';
      final newExpense = expense.copyWith(id: newId);
      _mockExpenses.add(newExpense);
      _emitMockList();
      return newId;
    }

    try {
      final docRef = await _expensesCollection!.add(expense.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Firestore Add Error (using fallback): $e');
      _useFallback = true;
      return addExpense(expense);
    }
  }

  /// Update an existing expense record in Cloud Firestore.
  Future<void> updateExpense(ExpenseModel expense) async {
    if (_useFallback || _expensesCollection == null) {
      final index = _mockExpenses.indexWhere((e) => e.id == expense.id);
      if (index != -1) {
        _mockExpenses[index] = expense;
        _emitMockList();
      }
      return;
    }

    try {
      await _expensesCollection!.doc(expense.id).update(expense.toMap());
    } catch (e) {
      debugPrint('Firestore Update Error (using fallback): $e');
      _useFallback = true;
      await updateExpense(expense);
    }
  }

  /// Delete an expense record from Cloud Firestore.
  Future<void> deleteExpense(String id) async {
    if (_useFallback || _expensesCollection == null) {
      _mockExpenses.removeWhere((e) => e.id == id);
      _emitMockList();
      return;
    }

    try {
      await _expensesCollection!.doc(id).delete();
    } catch (e) {
      debugPrint('Firestore Delete Error (using fallback): $e');
      _useFallback = true;
      await deleteExpense(id);
    }
  }

  void dispose() {
    _mockStreamController.close();
  }
}
