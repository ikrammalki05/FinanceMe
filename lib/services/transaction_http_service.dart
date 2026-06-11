// lib/services/transaction_http_service.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Service HTTP pour les Transactions
//  Utilisé par DataSourceController (Parties 2 et 3)
// ─────────────────────────────────────────────────────────────────────────────

import '../models/transaction_model.dart';
import 'api_service.dart';

class TransactionHttpService {
  static const String _endpoint = 'transactions';
  final ApiService _api;

  TransactionHttpService({required ApiService api}) : _api = api;

  /// GET /transactions?userId=x
  Future<List<TransactionModel>> getByUser(String userId) async {
    final data = await _api.getByUser(_endpoint, userId);
    final list =
        data.map((m) => TransactionModel.fromApiMap(m)).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// POST /transactions
  Future<TransactionModel> create(TransactionModel tx) async {
    final created = await _api.create(_endpoint, tx.toApiMap());
    return TransactionModel.fromApiMap(created);
  }

  /// PUT /transactions/:id
  Future<TransactionModel> update(TransactionModel tx) async {
    final updated =
        await _api.update(_endpoint, tx.id, tx.toApiMap());
    return TransactionModel.fromApiMap(updated);
  }

  /// DELETE /transactions/:id
  Future<bool> delete(String id) => _api.delete(_endpoint, id);
}
