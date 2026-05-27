// lib/controllers/budget_controller.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/budget_model.dart';
import '../models/transaction_model.dart';
import '../utils/database_helper.dart';

class BudgetController extends ChangeNotifier {
  List<BudgetModel> _budgets = [];
  final _db = DatabaseHelper();
  final _uuid = const Uuid();

  List<BudgetModel> get budgets => _budgets;

  Future<void> loadBudgets(String userId, int month, int year) async {
    _budgets = await _db.getBudgetsByMonth(userId, month, year);
    notifyListeners();
  }

  double getBudgetLimit(TransactionCategory category) {
    final budget = _budgets.where((b) => b.category == category).firstOrNull;
    return budget?.limit ?? 0.0;
  }

  Future<bool> setBudget({
    required String userId,
    required TransactionCategory category,
    required double limit,
    required int month,
    required int year,
  }) async {
    try {
      final existing =
          _budgets.where((b) => b.category == category).firstOrNull;
      if (existing != null) {
        final updated = BudgetModel(
          id: existing.id,
          userId: userId,
          category: category,
          limit: limit,
          month: month,
          year: year,
        );
        await _db.updateBudget(updated);
        final index = _budgets.indexOf(existing);
        _budgets[index] = updated;
      } else {
        final budget = BudgetModel(
          id: _uuid.v4(),
          userId: userId,
          category: category,
          limit: limit,
          month: month,
          year: year,
        );
        await _db.insertBudget(budget);
        _budgets.add(budget);
      }
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteBudget(String id) async {
    try {
      await _db.deleteBudget(id);
      _budgets.removeWhere((b) => b.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
