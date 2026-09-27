import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class ExpenseModel {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? note;
  final DateTime createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Create an [ExpenseModel] from a Firestore [DocumentSnapshot].
  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExpenseModel.fromMap(data, doc.id);
  }

  /// Create an [ExpenseModel] from a Map.
  factory ExpenseModel.fromMap(Map<String, dynamic> map, String docId) {
    return ExpenseModel(
      id: docId,
      title: map['title'] as String? ?? 'Untitled Expense',
      amount: (map['amount'] is num) ? (map['amount'] as num).toDouble() : 0.0,
      category: map['category'] as String? ?? 'Other',
      date: _parseDateTime(map['date']),
      note: map['note'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  /// Convert [ExpenseModel] to a Map suitable for Firestore storage.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Helper to safely parse dates from Timestamp, DateTime, String, or int (milliseconds).
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    } else if (value is String) {
      return DateTime.tryParse(value) ?? DateTime.now();
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.now();
  }

  /// Create a copy of [ExpenseModel] with updated fields.
  ExpenseModel copyWith({
    String? id,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Formatted currency string, e.g., "$45.50"
  String get formattedAmount {
    final formatter = NumberFormat.currency(
      symbol: AppConstants.currencySymbol,
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  /// Formatted date string, e.g., "Oct 24, 2025"
  String get formattedDate {
    return DateFormat.yMMMd().format(date);
  }

  /// Short date for cards, e.g., "Oct 24"
  String get formattedShortDate {
    return DateFormat.MMMd().format(date);
  }

  /// Formatted date & time string, e.g., "Oct 24, 2025 at 2:30 PM"
  String get formattedDateTime {
    return DateFormat.yMMMd().add_jm().format(date);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          amount == other.amount &&
          category == other.category &&
          date == other.date &&
          note == other.note;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      amount.hashCode ^
      category.hashCode ^
      date.hashCode ^
      note.hashCode;
}
