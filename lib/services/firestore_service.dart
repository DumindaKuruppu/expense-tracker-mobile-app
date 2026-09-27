import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../models/expense_model.dart';

/// Dedicated service class isolating Cloud Firestore operations.
class FirestoreService {
  final FirebaseFirestore? _firestore;
  String? _userId;

  // In-memory fallback list per user for unit testing environments without Firebase
  final Map<String, List<ExpenseModel>> _userMockExpenses = {};
  final StreamController<List<ExpenseModel>> _mockStreamController =
      StreamController<List<ExpenseModel>>.broadcast();

  FirestoreService({FirebaseFirestore? firestore, String? userId})
      : _firestore = firestore,
        _userId = userId {
    _initMockDataIfNeeded(_activeUserId);
  }

  bool get _isRealFirestoreAvailable {
    if (_firestore != null) return true;
    try {
      return FirebaseFirestore.instance.app != null;
    } catch (_) {
      return false;
    }
  }

  FirebaseFirestore get _firestoreInstance => _firestore ?? FirebaseFirestore.instance;

  String get _activeUserId => _userId ?? 'guest-default';

  void setUserId(String? userId) {
    if (_userId != userId) {
      _userId = userId;
      _initMockDataIfNeeded(_activeUserId);
      _emitMockList();
    }
  }

  void _initMockDataIfNeeded(String uid) {
    if (_userMockExpenses.containsKey(uid)) return;

    final now = DateTime.now();
    _userMockExpenses[uid] = [
      ExpenseModel(
        id: 'sample-1-$uid',
        title: 'Weekly Grocery Shopping',
        amount: 85.50,
        category: 'Food & Dining',
        date: now.subtract(const Duration(days: 1)),
        note: 'Supermarket supplies & vegetables',
      ),
      ExpenseModel(
        id: 'sample-2-$uid',
        title: 'Gas / Fuel Refill',
        amount: 45.00,
        category: 'Transport',
        date: now.subtract(const Duration(days: 2)),
        note: 'Full tank at Shell',
      ),
      ExpenseModel(
        id: 'sample-3-$uid',
        title: 'Electric & Power Bill',
        amount: 120.30,
        category: 'Bills & Utilities',
        date: now.subtract(const Duration(days: 3)),
        note: 'Monthly power consumption',
      ),
      ExpenseModel(
        id: 'sample-4-$uid',
        title: 'Cinema Movie Tickets',
        amount: 32.00,
        category: 'Entertainment',
        date: now.subtract(const Duration(days: 5)),
        note: 'IMAX weekend show',
      ),
    ];
  }

  List<ExpenseModel> get _currentMockExpenses {
    return _userMockExpenses[_activeUserId] ?? [];
  }

  CollectionReference<Map<String, dynamic>>? get _expensesCollection {
    if (!_isRealFirestoreAvailable) return null;
    if (_userId != null && _userId!.isNotEmpty) {
      return _firestoreInstance
          .collection('users')
          .doc(_userId)
          .collection(AppConstants.expensesCollection);
    }
    return _firestoreInstance.collection(AppConstants.expensesCollection);
  }

  /// Get real-time stream of expenses for the active user ordered by date descending.
  Stream<List<ExpenseModel>> getExpensesStream() {
    try {
      if (_isRealFirestoreAvailable && _expensesCollection != null) {
        return _expensesCollection!
            .orderBy('date', descending: true)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ExpenseModel.fromFirestore(doc);
          }).toList();
        }).handleError((error) {
          debugPrint('Firestore Stream Error: $error');
          _emitMockList();
          return _mockStreamController.stream;
        });
      }
    } catch (e) {
      debugPrint('Firestore Stream Exception: $e');
    }

    Timer.run(() => _emitMockList());
    return _mockStreamController.stream;
  }

  void _emitMockList() {
    final list = _currentMockExpenses;
    list.sort((a, b) => b.date.compareTo(a.date));
    if (!_mockStreamController.isClosed) {
      _mockStreamController.add(List.from(list));
    }
  }

  /// Add a new expense record to Cloud Firestore.
  Future<String> addExpense(ExpenseModel expense) async {
    try {
      if (_isRealFirestoreAvailable && _expensesCollection != null) {
        final docRef = await _expensesCollection!.add(expense.toMap());
        return docRef.id;
      }
    } catch (e) {
      debugPrint('Firestore Add Expense Exception: $e');
    }

    final newId = 'mock-${DateTime.now().millisecondsSinceEpoch}';
    final newExpense = expense.copyWith(id: newId);
    _currentMockExpenses.add(newExpense);
    _emitMockList();
    return newId;
  }

  /// Update an existing expense record in Cloud Firestore.
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      if (_isRealFirestoreAvailable && _expensesCollection != null) {
        await _expensesCollection!.doc(expense.id).update(expense.toMap());
        return;
      }
    } catch (e) {
      debugPrint('Firestore Update Expense Exception: $e');
    }

    final list = _currentMockExpenses;
    final index = list.indexWhere((e) => e.id == expense.id);
    if (index != -1) {
      list[index] = expense;
      _emitMockList();
    }
  }

  /// Delete an expense record from Cloud Firestore.
  Future<void> deleteExpense(String id) async {
    try {
      if (_isRealFirestoreAvailable && _expensesCollection != null) {
        await _expensesCollection!.doc(id).delete();
        return;
      }
    } catch (e) {
      debugPrint('Firestore Delete Expense Exception: $e');
    }

    _currentMockExpenses.removeWhere((e) => e.id == id);
    _emitMockList();
  }

  void dispose() {
    _mockStreamController.close();
  }
}
