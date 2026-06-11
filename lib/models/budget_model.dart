// lib/models/budget_model.dart

import 'transaction_model.dart';

class BudgetModel {
  final String id;
  final String userId;
  final TransactionCategory category;
  final double limit;
  final int month; // 1-12
  final int year;

  BudgetModel({
    required this.id,
    required this.userId,
    required this.category,
    required this.limit,
    required this.month,
    required this.year,
  });

  // ── Partie 1 : SQLite ─────────────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category.index,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'],
      userId: map['userId'],
      category: TransactionCategory.values[map['category']],
      limit: map['limit'],
      month: map['month'],
      year: map['year'],
    );
  }

  // ── Parties 2 & 3 : API HTTP ──────────────────────────────────────────────
  Map<String, dynamic> toApiMap() {
    return {
      'id': id,
      'userId': userId,
      'category': category.name,
      'limit': limit,
      'month': month,
      'year': year,
    };
  }

  factory BudgetModel.fromApiMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      category: TransactionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => TransactionCategory.otherExpense,
      ),
      limit: (map['limit'] as num).toDouble(),
      month: map['month'] as int,
      year: map['year'] as int,
    );
  }
}
