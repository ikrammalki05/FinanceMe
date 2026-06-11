// lib/views/screens/transactions_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionType? _filterType;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<TransactionModel> _filtered(List<TransactionModel> all) {
    return all.where((t) {
      final matchType = _filterType == null || t.type == _filterType;
      final matchSearch = _searchQuery.isEmpty ||
          t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.category.label.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchType && matchSearch;
    }).toList();
  }

  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> list) {
    final Map<String, List<TransactionModel>> groups = {};
    for (final t in list) {
      final key = DateFormat('MMMM yyyy', 'fr_FR').format(t.date);
      groups.putIfAbsent(key, () => []).add(t);
    }
    return groups;
  }

  Future<void> _confirmDelete(BuildContext context, TransactionModel t) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${t.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Supprimer', style: TextStyle(color: AppTheme.accent))),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await context.read<TransactionController>().deleteTransaction(t.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction supprimée'), backgroundColor: AppTheme.accent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final txCtrl = context.watch<TransactionController>();
    final filtered = _filtered(txCtrl.transactions);
    final groups = _groupByDate(filtered);

    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Search + filter
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search, size: 20),
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                const SizedBox(width: 10),
                _FilterChip(label: 'Tous', isSelected: _filterType == null, onTap: () => setState(() => _filterType = null)),
                const SizedBox(width: 6),
                _FilterChip(label: 'Revenus', isSelected: _filterType == TransactionType.income, color: AppTheme.incomeColor, onTap: () => setState(() => _filterType = _filterType == TransactionType.income ? null : TransactionType.income)),
                const SizedBox(width: 6),
                _FilterChip(label: 'Dépenses', isSelected: _filterType == TransactionType.expense, color: AppTheme.expenseColor, onTap: () => setState(() => _filterType = _filterType == TransactionType.expense ? null : TransactionType.expense)),
              ],
            ),
          ),

          Expanded(
            child: filtered.isEmpty
                ? Center(child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_off, size: 56, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text('Aucun résultat', style: TextStyle(color: Colors.grey.shade500)),
                    ],
                  ))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                    itemCount: groups.length,
                    itemBuilder: (context, i) {
                      final key = groups.keys.elementAt(i);
                      final items = groups[key]!;
                      final currency = context.read<AuthController>().currentUser?.currency ?? 'MAD';
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(key.toUpperCase(),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(letterSpacing: 1, fontWeight: FontWeight.w700)),
                          ),
                          ...items.map((t) => TransactionTile(
                            transaction: t,
                            currency: currency,
                            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTransactionScreen(transaction: t))),
                            onDelete: () => _confirmDelete(context, t),
                          )),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, this.color = AppTheme.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : Colors.transparent),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : Colors.grey)),
      ),
    );
  }
}
