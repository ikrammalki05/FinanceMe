// lib/views/screens/budgets_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/budget_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  final now = DateTime.now();

  void _showBudgetDialog(BuildContext context, TransactionCategory category, double currentLimit) {
    final ctrl = TextEditingController(text: currentLimit > 0 ? currentLimit.toStringAsFixed(0) : '');
    final currency = context.read<AuthController>().currentUser?.currency ?? 'MAD';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 20, top: 20, left: 20, right: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Budget – ${category.icon} ${category.label}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Limite ($currency)',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final limit = double.tryParse(ctrl.text) ?? 0;
                if (limit <= 0) return;
                final userId = context.read<AuthController>().currentUser!.id;
                await context.read<BudgetController>().setBudget(
                  userId: userId,
                  category: category,
                  limit: limit,
                  month: now.month,
                  year: now.year,
                );
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetCtrl = context.watch<BudgetController>();
    final txCtrl = context.watch<TransactionController>();
    final auth = context.watch<AuthController>();
    final currency = auth.currentUser?.currency ?? 'MAD';
    final expenseCategories = TransactionCategory.values.where((c) => c.type == TransactionType.expense).toList();
    final monthlyExpenses = txCtrl.getExpensesByCategory(now.month, now.year);

    return Scaffold(
      appBar: AppBar(title: Text('Budgets – ${DateFormat('MMMM yyyy', 'fr_FR').format(now)}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: AppTheme.primary.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(child: Text('Définissez des limites mensuelles par catégorie pour mieux contrôler vos dépenses.', style: TextStyle(fontSize: 13, color: AppTheme.primary.withOpacity(0.9)))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
          ...expenseCategories.map((cat) {
            final limit = budgetCtrl.getBudgetLimit(cat);
            final spent = monthlyExpenses[cat] ?? 0.0;
            final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
            final color = progress > 0.8 ? AppTheme.accent : AppTheme.primary;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => _showBudgetDialog(context, cat, limit),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(cat.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                        if (limit > 0)
                          Text('${NumberFormat('#,##0', 'fr_FR').format(spent)} / ${NumberFormat('#,##0', 'fr_FR').format(limit)} $currency',
                              style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600))
                        else
                          Text('Définir un budget', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      ]),
                      if (limit > 0) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(value: progress, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation(color), minHeight: 6),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          progress >= 1.0 ? '⚠️ Budget dépassé !' : '${(progress * 100).toStringAsFixed(0)}% utilisé',
                          style: TextStyle(fontSize: 11, color: progress >= 1.0 ? AppTheme.accent : Colors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
