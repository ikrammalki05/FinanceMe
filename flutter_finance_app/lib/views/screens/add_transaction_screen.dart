// lib/views/screens/add_transaction_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/transaction_controller.dart';
import '../../models/transaction_model.dart';
import '../../utils/app_theme.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transaction; // null = add, non-null = edit
  const AddTransactionScreen({super.key, this.transaction});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  TransactionType _type = TransactionType.expense;
  TransactionCategory? _category;
  DateTime _date = DateTime.now();
  bool _isSaving = false;

  bool get isEdit => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final t = widget.transaction!;
      _titleCtrl.text = t.title;
      _amountCtrl.text = t.amount.toString();
      _noteCtrl.text = t.note ?? '';
      _type = t.type;
      _category = t.category;
      _date = t.date;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  List<TransactionCategory> get _filteredCategories => TransactionCategory.values
      .where((c) => c.type == _type)
      .toList();

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez choisir une catégorie')),
      );
      return;
    }

    setState(() => _isSaving = true);
    final userId = context.read<AuthController>().currentUser!.id;
    final ctrl = context.read<TransactionController>();
    bool success;

    if (isEdit) {
      success = await ctrl.updateTransaction(
        id: widget.transaction!.id,
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        category: _category!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    } else {
      success = await ctrl.addTransaction(
        userId: userId,
        title: _titleCtrl.text.trim(),
        amount: double.parse(_amountCtrl.text.replaceAll(',', '.')),
        category: _category!,
        date: _date,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
      );
    }

    setState(() => _isSaving = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Transaction modifiée !' : 'Transaction ajoutée !'),
          backgroundColor: AppTheme.primary,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier' : 'Nouvelle transaction'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Type toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2D3E) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeButton(
                    label: 'Dépense',
                    icon: Icons.arrow_upward_rounded,
                    color: AppTheme.expenseColor,
                    isSelected: _type == TransactionType.expense,
                    onTap: () => setState(() {
                      _type = TransactionType.expense;
                      _category = null;
                    }),
                  ),
                  _TypeButton(
                    label: 'Revenu',
                    icon: Icons.arrow_downward_rounded,
                    color: AppTheme.incomeColor,
                    isSelected: _type == TransactionType.income,
                    onTap: () => setState(() {
                      _type = TransactionType.income;
                      _category = null;
                    }),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titre',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),

            // Amount
            TextFormField(
              controller: _amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Montant',
                prefixIcon: Icon(Icons.attach_money),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Requis';
                final n = double.tryParse(v.replaceAll(',', '.'));
                if (n == null || n <= 0) return 'Montant invalide';
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            Text('Catégorie', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredCategories.map((cat) {
                final isSelected = _category == cat;
                final color = _type == TransactionType.income ? AppTheme.incomeColor : AppTheme.expenseColor;
                return GestureDetector(
                  onTap: () => setState(() => _category = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.15) : (isDark ? const Color(0xFF2A2D3E) : Colors.grey.shade100),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? color : Colors.transparent, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cat.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(cat.label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : null)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Date
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2D3E) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF3A3D4E) : Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Text(DateFormat('d MMMM yyyy', 'fr_FR').format(_date),
                        style: Theme.of(context).textTheme.bodyMedium),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Note
            TextFormField(
              controller: _noteCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Note (optionnel)',
                prefixIcon: Icon(Icons.note_outlined),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),

            // Save button
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text(isEdit ? 'Modifier' : 'Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({required this.label, required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.grey, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}
