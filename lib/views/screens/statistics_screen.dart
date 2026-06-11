// lib/views/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../controllers/budget_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txCtrl = context.watch<TransactionController>();
    final auth = context.watch<AuthController>();
    final currency = auth.currentUser?.currency ?? 'MAD';
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Aperçu'),
            Tab(text: 'Catégories'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _OverviewTab(txCtrl: txCtrl, currency: currency),
          _CategoriesTab(txCtrl: txCtrl, currency: currency, month: now.month, year: now.year),
        ],
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────────
class _OverviewTab extends StatelessWidget {
  final TransactionController txCtrl;
  final String currency;
  const _OverviewTab({required this.txCtrl, required this.currency});

  static const _monthNames = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Jun', 'Jul', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];

  @override
  Widget build(BuildContext context) {
    final data = txCtrl.getMonthlyTotals();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('6 derniers mois', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        SizedBox(
          height: 220,
          child: BarChart(
            BarChartData(
              barGroups: data.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: (d['income'] as double), color: AppTheme.incomeColor, width: 10, borderRadius: BorderRadius.circular(4)),
                  BarChartRodData(toY: (d['expense'] as double), color: AppTheme.expenseColor, width: 10, borderRadius: BorderRadius.circular(4)),
                ]);
              }).toList(),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: (isDark ? Colors.white12 : Colors.black12), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 45, getTitlesWidget: (v, _) => Text(NumberFormat.compact().format(v), style: const TextStyle(fontSize: 10)))),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= data.length) return const SizedBox();
                  final m = (data[i]['month'] as int) - 1;
                  return Text(_monthNames[m], style: const TextStyle(fontSize: 11));
                })),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _LegendDot(color: AppTheme.incomeColor, label: 'Revenus'),
            const SizedBox(width: 20),
            _LegendDot(color: AppTheme.expenseColor, label: 'Dépenses'),
          ],
        ),
        const SizedBox(height: 28),
        // Monthly summary cards
        ...data.reversed.take(3).map((d) => _MonthSummaryCard(data: d, currency: currency)),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
    const SizedBox(width: 6),
    Text(label, style: const TextStyle(fontSize: 12)),
  ]);
}

class _MonthSummaryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String currency;
  const _MonthSummaryCard({required this.data, required this.currency});

  static const _monthNames = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];

  @override
  Widget build(BuildContext context) {
    final income = data['income'] as double;
    final expense = data['expense'] as double;
    final net = income - expense;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: Text('${_monthNames[data['month'] as int]} ${data['year']}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('+${NumberFormat('#,##0', 'fr_FR').format(income)} $currency', style: const TextStyle(color: AppTheme.incomeColor, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('-${NumberFormat('#,##0', 'fr_FR').format(expense)} $currency', style: const TextStyle(color: AppTheme.expenseColor, fontSize: 12, fontWeight: FontWeight.w600)),
              Text('${net >= 0 ? '+' : ''}${NumberFormat('#,##0', 'fr_FR').format(net)} $currency',
                  style: TextStyle(color: net >= 0 ? AppTheme.incomeColor : AppTheme.expenseColor, fontSize: 13, fontWeight: FontWeight.w700)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Categories Tab ────────────────────────────────────────────
class _CategoriesTab extends StatelessWidget {
  final TransactionController txCtrl;
  final String currency;
  final int month, year;
  const _CategoriesTab({required this.txCtrl, required this.currency, required this.month, required this.year});

  @override
  Widget build(BuildContext context) {
    final byCategory = txCtrl.getExpensesByCategory(month, year);
    final total = byCategory.values.fold(0.0, (s, v) => s + v);

    if (byCategory.isEmpty) {
      return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.pie_chart_outline, size: 60, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Text('Aucune dépense ce mois', style: TextStyle(color: Colors.grey.shade500)),
      ]));
    }

    final colors = [
      const Color(0xFFFF6B6B), const Color(0xFF4ECDC4), const Color(0xFF45B7D1),
      const Color(0xFFFFA07A), const Color(0xFF98D8C8), const Color(0xFFDDA0DD),
      const Color(0xFF90EE90), const Color(0xFFF0E68C), const Color(0xFFB0C4DE),
    ];

    final sections = byCategory.entries.toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Dépenses par catégorie', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(DateFormat('MMMM yyyy', 'fr_FR').format(DateTime(year, month)), style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 24),

        // Pie chart
        SizedBox(
          height: 220,
          child: PieChart(PieChartData(
            sections: sections.asMap().entries.map((e) {
              final i = e.key;
              final cat = e.value.key;
              final amt = e.value.value;
              return PieChartSectionData(
                value: amt,
                color: colors[i % colors.length],
                title: '${(amt / total * 100).toStringAsFixed(0)}%',
                radius: 80,
                titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                badgeWidget: Text(cat.icon, style: const TextStyle(fontSize: 18)),
                badgePositionPercentageOffset: 1.3,
              );
            }).toList(),
            sectionsSpace: 2,
            centerSpaceRadius: 40,
          )),
        ),
        const SizedBox(height: 24),

        // Category list
        ...sections.asMap().entries.map((e) {
          final i = e.key;
          final cat = e.value.key;
          final amt = e.value.value;
          final pct = total > 0 ? amt / total : 0.0;
          final color = colors[i % colors.length];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(cat.icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 10),
                    Expanded(child: Text(cat.label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                    Text('${NumberFormat('#,##0.00', 'fr_FR').format(amt)} $currency',
                        style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                  ]),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(value: pct, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation(color), minHeight: 6),
                  ),
                  const SizedBox(height: 4),
                  Text('${(pct * 100).toStringAsFixed(1)}% des dépenses', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
