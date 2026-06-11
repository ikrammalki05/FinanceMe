// lib/controllers/transaction_controller.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';

class TransactionController extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  final _db = DatabaseHelper();
  final _uuid = const Uuid();

  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;

  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  List<TransactionModel> getByMonth(int month, int year) {
    return _transactions.where((t) {
      return t.date.month == month && t.date.year == year;
    }).toList();
  }

  Map<TransactionCategory, double> getExpensesByCategory(
      int month, int year) {
    final monthly = getByMonth(month, year)
        .where((t) => t.type == TransactionType.expense);
    final Map<TransactionCategory, double> result = {};
    for (final t in monthly) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  // Monthly totals for chart (last 6 months)
  List<Map<String, dynamic>> getMonthlyTotals() {
    final List<Map<String, dynamic>> result = [];
    final now = DateTime.now();
    for (int i = 5; i >= 0; i--) {
      final month = now.month - i;
      final year = now.year + (month <= 0 ? -1 : 0);
      final adjustedMonth = month <= 0 ? month + 12 : month;
      final monthly = getByMonth(adjustedMonth, year);
      result.add({
        'month': adjustedMonth,
        'year': year,
        'income': monthly
            .where((t) => t.type == TransactionType.income)
            .fold(0.0, (s, t) => s + t.amount),
        'expense': monthly
            .where((t) => t.type == TransactionType.expense)
            .fold(0.0, (s, t) => s + t.amount),
      });
    }
    return result;
  }

  Future<void> loadTransactions(String userId) async {
    _isLoading = true;
    notifyListeners();
    _transactions = await _db.getTransactionsByUser(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required TransactionCategory category,
    required DateTime date,
    String? note,
  }) async {
    try {
      final transaction = TransactionModel(
        id: _uuid.v4(),
        title: title,
        amount: amount,
        type: category.type,
        category: category,
        date: date,
        note: note,
        userId: userId,
      );
      await _db.insertTransaction(transaction);
      _transactions.insert(0, transaction);
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required TransactionCategory category,
    required DateTime date,
    String? note,
  }) async {
    try {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index == -1) return false;

      final updated = _transactions[index].copyWith(
        title: title,
        amount: amount,
        type: category.type,
        category: category,
        date: date,
        note: note,
      );
      await _db.updateTransaction(updated);
      _transactions[index] = updated;
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteTransaction(String id) async {
    try {
      await _db.deleteTransaction(id);
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
