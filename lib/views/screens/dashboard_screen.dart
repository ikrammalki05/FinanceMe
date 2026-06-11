// lib/views/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final txCtrl = context.watch<TransactionController>();
    final user = auth.currentUser;
    final now = DateTime.now();
    final monthly = txCtrl.getByMonth(now.month, now.year);
    final monthlyIncome = monthly
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (s, t) => s + t.amount);
    final monthlyExpense = monthly
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (s, t) => s + t.amount);
    final currency = user?.currency ?? 'MAD';
    final recent = txCtrl.transactions.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, ${user?.name.split(' ').first ?? ''} 👋',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            Text(DateFormat('EEEE d MMMM', 'fr_FR').format(now),
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransactionScreen())),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter'),
      ),
      body: txCtrl.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                if (user != null) await txCtrl.loadTransactions(user.id);
              },
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Balance Card
                  _BalanceCard(
                    balance: txCtrl.balance,
                    income: monthlyIncome,
                    expense: monthlyExpense,
                    currency: currency,
                  ),
                  const SizedBox(height: 24),

                  // Budget progress (if set)
                  if ((user?.monthlyBudget ?? 0) > 0) ...[
                    _BudgetProgress(budget: user!.monthlyBudget, spent: monthlyExpense, currency: currency),
                    const SizedBox(height: 24),
                  ],

                  // Recent transactions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transactions récentes',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (recent.isEmpty)
                    _EmptyState()
                  else
                    ...recent.map((t) => TransactionTile(transaction: t, currency: currency)),
                ],
              ),
            ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final double balance, income, expense;
  final String currency;
  const _BalanceCard({required this.balance, required this.income, required this.expense, required this.currency});

  String _fmt(double v) => NumberFormat('#,##0.00', 'fr_FR').format(v);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00C896), Color(0xFF00A0C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Solde total', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text('${_fmt(balance)} $currency',
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _StatItem(label: 'Revenus', value: '${_fmt(income)} $currency', icon: Icons.arrow_downward_rounded, color: Colors.white)),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(child: _StatItem(label: 'Dépenses', value: '${_fmt(expense)} $currency', icon: Icons.arrow_upward_rounded, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final double budget, spent;
  final String currency;
  const _BudgetProgress({required this.budget, required this.spent, required this.currency});

  @override
  Widget build(BuildContext context) {
    final progress = (spent / budget).clamp(0.0, 1.0);
    final color = progress > 0.8 ? AppTheme.accent : AppTheme.primary;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Budget mensuel', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                Text('${NumberFormat('#,##0', 'fr_FR').format(spent)} / ${NumberFormat('#,##0', 'fr_FR').format(budget)} $currency',
                    style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 6),
            Text('${(progress * 100).toStringAsFixed(0)}% utilisé',
                style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text('Aucune transaction', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('Appuyez sur + pour ajouter', style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
        ],
      ),
    );
  }
}
