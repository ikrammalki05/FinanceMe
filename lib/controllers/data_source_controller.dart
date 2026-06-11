// lib/controllers/data_source_controller.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Contrôleur de Source de Données
//
//  Gère les 3 backends du TP et expose une interface UNIQUE aux écrans :
//
//  ┌─────────────────────────────────────────────────────────────────────────┐
//  │  PARTIE 1 — SQLite      : DataSource.sqlite                            │
//  │  PARTIE 2 — JSON Server : DataSource.jsonServer  (API locale)          │
//  │  PARTIE 3 — Cloud API   : DataSource.cloud       (API distante)        │
//  └─────────────────────────────────────────────────────────────────────────┘
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/transaction_model.dart';
import '../services/api_service.dart';
import '../services/transaction_http_service.dart';
import '../utils/database_helper.dart';

// ── Enumération des sources ───────────────────────────────────────────────────
enum DataSource {
  sqlite,    // Partie 1 — Base de données locale SQLite
  jsonServer, // Partie 2 — API locale via json-server
  cloud,     // Partie 3 — API déployée sur le Cloud
}

extension DataSourceExtension on DataSource {
  String get label {
    switch (this) {
      case DataSource.sqlite:
        return 'SQLite (Local)';
      case DataSource.jsonServer:
        return 'JSON Server (API locale)';
      case DataSource.cloud:
        return 'Cloud API';
    }
  }

  String get description {
    switch (this) {
      case DataSource.sqlite:
        return 'Partie 1 — Données stockées directement sur l\'appareil avec SQLite.';
      case DataSource.jsonServer:
        return 'Partie 2 — Données via une API REST locale (json-server sur votre PC).';
      case DataSource.cloud:
        return 'Partie 3 — Données via une API REST déployée sur le Cloud.';
    }
  }

  String get icon {
    switch (this) {
      case DataSource.sqlite:
        return '🗄️';
      case DataSource.jsonServer:
        return '🖥️';
      case DataSource.cloud:
        return '☁️';
    }
  }
}

// ── Contrôleur principal ──────────────────────────────────────────────────────
class DataSourceController extends ChangeNotifier {
  // ── État ───────────────────────────────────────────────────────────────────
  DataSource _source = DataSource.sqlite;
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _error;

  // ── Getters ────────────────────────────────────────────────────────────────
  DataSource get source => _source;
  List<TransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Dépendances ────────────────────────────────────────────────────────────
  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // ── Retourne le service HTTP selon la source active ────────────────────────
  TransactionHttpService _httpService() {
    final baseUrl = _source == DataSource.jsonServer
        ? ApiConfig.localUrl
        : ApiConfig.cloudUrl;
    return TransactionHttpService(api: ApiService(baseUrl: baseUrl));
  }

  // ── Changer la source de données ──────────────────────────────────────────
  void setSource(DataSource source) {
    _source = source;
    _transactions = [];
    _error = null;
    notifyListeners();
  }

  // ── CHARGEMENT ────────────────────────────────────────────────────────────

  /// Charger les transactions depuis la source active
  Future<void> loadTransactions(String userId) async {
    _setLoading(true);
    _error = null;

    try {
      if (_source == DataSource.sqlite) {
        // ── Partie 1 : SQLite ───────────────────────────────────────────────
        _transactions = await _db.getTransactionsByUser(userId);
      } else {
        // ── Parties 2 & 3 : API HTTP ────────────────────────────────────────
        _transactions = await _httpService().getByUser(userId);
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('[DataSourceController] loadTransactions error: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  /// Ajouter une transaction dans la source active
  Future<bool> addTransaction({
    required String userId,
    required String title,
    required double amount,
    required TransactionCategory category,
    required DateTime date,
    String? note,
  }) async {
    final tx = TransactionModel(
      id: _uuid.v4(),
      title: title,
      amount: amount,
      type: category.type,
      category: category,
      date: date,
      note: note,
      userId: userId,
    );

    try {
      if (_source == DataSource.sqlite) {
        // ── Partie 1 : SQLite ───────────────────────────────────────────────
        await _db.insertTransaction(tx);
        _transactions.insert(0, tx);
      } else {
        // ── Parties 2 & 3 : API HTTP ────────────────────────────────────────
        final created = await _httpService().create(tx);
        _transactions.insert(0, created);
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de l\'ajout : $e';
      notifyListeners();
      return false;
    }
  }

  /// Modifier une transaction dans la source active
  Future<bool> updateTransaction({
    required String id,
    required String title,
    required double amount,
    required TransactionCategory category,
    required DateTime date,
    String? note,
  }) async {
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

    try {
      if (_source == DataSource.sqlite) {
        await _db.updateTransaction(updated);
        _transactions[index] = updated;
      } else {
        final result = await _httpService().update(updated);
        _transactions[index] = result;
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la modification : $e';
      notifyListeners();
      return false;
    }
  }

  /// Supprimer une transaction de la source active
  Future<bool> deleteTransaction(String id) async {
    try {
      if (_source == DataSource.sqlite) {
        await _db.deleteTransaction(id);
      } else {
        await _httpService().delete(id);
      }
      _transactions.removeWhere((t) => t.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Erreur lors de la suppression : $e';
      notifyListeners();
      return false;
    }
  }

  // ── Calculs utilitaires ───────────────────────────────────────────────────
  double get totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (s, t) => s + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (s, t) => s + t.amount);

  double get balance => totalIncome - totalExpense;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}
