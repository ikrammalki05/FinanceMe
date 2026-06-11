// lib/views/screens/data_source_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Écran "Source de Données" — Démontre les 3 parties du TP
//
//  PARTIE 1 — SQLite      : lecture/écriture en base locale
//  PARTIE 2 — JSON Server : API REST locale (json-server)
//  PARTIE 3 — Cloud API   : API REST distante
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/data_source_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';

class DataSourceScreen extends StatefulWidget {
  const DataSourceScreen({super.key});

  @override
  State<DataSourceScreen> createState() => _DataSourceScreenState();
}

class _DataSourceScreenState extends State<DataSourceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _sources = [
    DataSource.sqlite,
    DataSource.jsonServer,
    DataSource.cloud,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _switchAndLoad(_sources[_tabController.index]);
      }
    });
    // Charge la source active au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctrl = context.read<DataSourceController>();
      final userId = context.read<AuthController>().currentUser?.id;
      if (userId != null) ctrl.loadTransactions(userId);
    });
  }

  void _switchAndLoad(DataSource src) {
    final ctrl = context.read<DataSourceController>();
    final userId = context.read<AuthController>().currentUser?.id;
    ctrl.setSource(src);
    if (userId != null) ctrl.loadTransactions(userId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Source de Données'),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(
              fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(text: 'Partie 1\nSQLite', height: 48),
            Tab(text: 'Partie 2\nJSON Server', height: 48),
            Tab(text: 'Partie 3\nCloud API', height: 48),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _sources
            .map((src) => _DataSourceTab(source: src))
            .toList(),
      ),
    );
  }
}

// ─── Onglet pour une source ───────────────────────────────────────────────────
class _DataSourceTab extends StatelessWidget {
  final DataSource source;

  const _DataSourceTab({required this.source});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<DataSourceController>();
    final isActive = ctrl.source == source;

    return Column(
      children: [
        // ── Bannière d'information ────────────────────────────────────────
        _InfoBanner(source: source, isActive: isActive),

        // ── Contenu principal ─────────────────────────────────────────────
        Expanded(
          child: !isActive
              ? _InactiveOverlay(source: source)
              : ctrl.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primary,
                      ),
                    )
                  : ctrl.error != null
                      ? _ErrorView(
                          source: source,
                          message: ctrl.error!,
                        )
                      : ctrl.transactions.isEmpty
                          ? _EmptyView(source: source)
                          : _TransactionList(
                              transactions: ctrl.transactions,
                              source: source,
                            ),
        ),

        // ── Bouton Ajouter ────────────────────────────────────────────────
        if (isActive) _AddButton(source: source),
      ],
    );
  }
}

// ─── Bannière d'info source ───────────────────────────────────────────────────
class _InfoBanner extends StatelessWidget {
  final DataSource source;
  final bool isActive;

  const _InfoBanner({required this.source, required this.isActive});

  Color get _color {
    switch (source) {
      case DataSource.sqlite:
        return Colors.green;
      case DataSource.jsonServer:
        return Colors.orange;
      case DataSource.cloud:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: _color.withOpacity(0.12),
      child: Row(
        children: [
          Text(source.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  source.label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _color.shade700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  source.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: _color.shade700.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isActive ? _color : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActive ? 'Active' : 'Inactive',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Overlay quand l'onglet n'est pas actif ───────────────────────────────────
class _InactiveOverlay extends StatelessWidget {
  final DataSource source;

  const _InactiveOverlay({required this.source});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Cliquez sur l\'onglet pour activer\ncette source de données',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Vue erreur ───────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final DataSource source;
  final String message;

  const _ErrorView({required this.source, required this.message});

  @override
  Widget build(BuildContext context) {
    final isNetwork = source != DataSource.sqlite;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isNetwork ? Icons.wifi_off_rounded : Icons.error_outline,
              size: 56,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isNetwork
                  ? 'Impossible de joindre le serveur'
                  : 'Erreur de base de données',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (isNetwork) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  source == DataSource.jsonServer
                      ? '💡 Assurez-vous que json-server est lancé :\n'
                          'npm install -g json-server\n'
                          'json-server --watch db.json --port 3000'
                      : '💡 Vérifiez l\'URL dans ApiConfig.cloudUrl\n'
                          '(lib/services/api_service.dart)',
                  style: const TextStyle(
                      fontSize: 11, color: Colors.deepOrange),
                  textAlign: TextAlign.left,
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                final ctrl = context.read<DataSourceController>();
                final userId = context
                    .read<AuthController>()
                    .currentUser
                    ?.id;
                ctrl.clearError();
                if (userId != null) ctrl.loadTransactions(userId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Vue vide ─────────────────────────────────────────────────────────────────
class _EmptyView extends StatelessWidget {
  final DataSource source;

  const _EmptyView({required this.source});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(source.icon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          const Text(
            'Aucune transaction',
            style:
                TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            'Ajoutez votre première transaction via\ncette source.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─── Liste de transactions ────────────────────────────────────────────────────
class _TransactionList extends StatelessWidget {
  final List<TransactionModel> transactions;
  final DataSource source;

  const _TransactionList(
      {required this.transactions, required this.source});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'fr_MA', symbol: 'MAD');
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final tx = transactions[i];
        final isIncome = tx.type == TransactionType.income;
        return Dismissible(
          key: Key(tx.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.red.shade400,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.delete_outline,
                color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Supprimer ?'),
                content: Text(
                    'Supprimer "${tx.title}" de la source ${source.label} ?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Annuler')),
                  TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Supprimer',
                          style:
                              TextStyle(color: Colors.red))),
                ],
              ),
            );
          },
          onDismissed: (_) {
            context
                .read<DataSourceController>()
                .deleteTransaction(tx.id);
          },
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (isIncome ? Colors.green : Colors.red)
                      .withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(tx.category.icon,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              title: Text(tx.title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(
                '${tx.category.label} · ${DateFormat('dd/MM/yyyy').format(tx.date)}',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Text(
                '${isIncome ? '+' : '-'} ${fmt.format(tx.amount)}',
                style: TextStyle(
                  color: isIncome
                      ? Colors.green.shade600
                      : Colors.red.shade500,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Bouton Ajouter ───────────────────────────────────────────────────────────
class _AddButton extends StatelessWidget {
  final DataSource source;

  const _AddButton({required this.source});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
          onPressed: () => _showAddSheet(context),
          icon: const Icon(Icons.add),
          label: Text('Ajouter via ${source.label}'),
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    TransactionCategory selectedCat = TransactionCategory.food;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: StatefulBuilder(
            builder: (ctx2, setS) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nouvelle transaction — ${source.icon} ${source.label}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    prefixIcon: Icon(Icons.edit_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Montant (MAD)',
                    prefixIcon:
                        Icon(Icons.account_balance_wallet_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<TransactionCategory>(
                  value: selectedCat,
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: TransactionCategory.values
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child:
                                Text('${c.icon} ${c.label}'),
                          ))
                      .toList(),
                  onChanged: (v) =>
                      setS(() => selectedCat = v!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(46)),
                  onPressed: () async {
                    final title = titleCtrl.text.trim();
                    final amount =
                        double.tryParse(amountCtrl.text.trim());
                    if (title.isEmpty || amount == null || amount <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content:
                                Text('Veuillez remplir tous les champs')),
                      );
                      return;
                    }
                    final userId = context
                        .read<AuthController>()
                        .currentUser
                        ?.id;
                    if (userId == null) return;

                    Navigator.pop(ctx);
                    final ok = await context
                        .read<DataSourceController>()
                        .addTransaction(
                          userId: userId,
                          title: title,
                          amount: amount,
                          category: selectedCat,
                          date: DateTime.now(),
                        );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(ok
                            ? '✅ Transaction ajoutée via ${source.label}'
                            : '❌ Échec de l\'ajout'),
                        backgroundColor:
                            ok ? AppTheme.primary : Colors.red,
                      ));
                    }
                  },
                  child: const Text('Enregistrer'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Extension couleur pour Color ───────────────────────────────────────────────
extension ColorShade on Color {
  Color get shade700 => HSLColor.fromColor(this)
      .withLightness(
          (HSLColor.fromColor(this).lightness - 0.15).clamp(0.0, 1.0))
      .toColor();
}
