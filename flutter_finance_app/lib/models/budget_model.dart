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
}
