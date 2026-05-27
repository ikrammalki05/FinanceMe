// lib/views/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/theme_controller.dart';
import '../../utils/app_theme.dart';

import 'login_screen.dart';
import 'budgets_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _budgetCtrl;

  String _currency = 'MAD';

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    final user = context.read<AuthController>().currentUser;

    _nameCtrl = TextEditingController(
      text: user?.name ?? '',
    );

    _budgetCtrl = TextEditingController(
      text: user?.monthlyBudget.toString() ?? '0',
    );

    _currency = user?.currency ?? 'MAD';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _budgetCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await context.read<AuthController>().updateProfile(
      name: _nameCtrl.text.trim(),
      currency: _currency,
      monthlyBudget:
      double.tryParse(_budgetCtrl.text) ?? 0,
    );

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour !'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text(
          'Voulez-vous vous déconnecter ?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text(
              'Déconnexion',
              style: TextStyle(
                color: AppTheme.accent,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<AuthController>().logout();

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final themeCtrl =
    context.watch<ThemeController>();

    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing
                  ? Icons.close
                  : Icons.edit_outlined,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // Avatar
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor:
                  AppTheme.primary.withOpacity(0.15),

                  child: Text(
                    user?.name.isNotEmpty == true
                        ? user!.name[0].toUpperCase()
                        : '?',

                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  user?.name ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .displayMedium
                      ?.copyWith(fontSize: 20),
                ),

                Text(
                  user?.email ?? '',
                  style:
                  Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Edit Form
          if (_isEditing)
            Form(
              key: _formKey,

              child: Column(
                children: [
                  TextFormField(
                    controller: _nameCtrl,

                    decoration: const InputDecoration(
                      labelText: 'Nom complet',
                      prefixIcon:
                      Icon(Icons.person_outline),
                    ),

                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Requis';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    value: _currency,

                    decoration: const InputDecoration(
                      labelText: 'Devise',
                      prefixIcon:
                      Icon(Icons.currency_exchange),
                    ),

                    items: AppConstants.currencies
                        .map(
                          (c) => DropdownMenuItem(
                        value: c,
                        child: Text(c),
                      ),
                    )
                        .toList(),

                    onChanged: (v) {
                      setState(() {
                        _currency = v!;
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _budgetCtrl,
                    keyboardType:
                    TextInputType.number,

                    decoration: const InputDecoration(
                      labelText: 'Budget mensuel',
                      prefixIcon: Icon(
                        Icons
                            .account_balance_wallet_outlined,
                      ),
                    ),

                    validator: (v) {
                      if (v != null &&
                          v.isNotEmpty &&
                          double.tryParse(v) == null) {
                        return 'Montant invalide';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed:
                    _isSaving ? null : _saveProfile,

                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Enregistrer'),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

          // Settings
          _SectionTitle('Paramètres'),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    themeCtrl.isDarkMode
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,

                    color: AppTheme.primary,
                  ),

                  title: const Text('Mode sombre'),

                  trailing: Switch(
                    value: themeCtrl.isDarkMode,

                    onChanged: (_) {
                      themeCtrl.toggleTheme();
                    },

                    activeColor: AppTheme.primary,
                  ),
                ),

                const Divider(
                  height: 1,
                  indent: 56,
                ),

                ListTile(
                  leading: const Icon(
                    Icons.pie_chart_outline,
                    color: AppTheme.primary,
                  ),

                  title: const Text(
                    'Gérer les budgets',
                  ),

                  trailing:
                  const Icon(Icons.chevron_right),

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                        const BudgetsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          _SectionTitle('Compte'),

          Card(
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: AppTheme.accent,
              ),

              title: const Text(
                'Déconnexion',
                style: TextStyle(
                  color: AppTheme.accent,
                ),
              ),

              onTap: _logout,
            ),
          ),

          const SizedBox(height: 32),

          Center(
            child: Text(
              'FinanceMe v1.0.0',
              style:
              Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),

      child: Text(
        title,

        style: Theme.of(context)
            .textTheme
            .bodySmall
            ?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }
}