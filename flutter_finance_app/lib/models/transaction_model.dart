// lib/models/transaction_model.dart

enum TransactionType { income, expense }

enum TransactionCategory {
  // Revenus
  salary,
  freelance,
  investment,
  gift,
  otherIncome,

  // Dépenses
  food,
  transport,
  housing,
  health,
  entertainment,
  shopping,
  education,
  utilities,
  otherExpense,
}

extension TransactionCategoryExtension on TransactionCategory {
  String get label {
    switch (this) {
      case TransactionCategory.salary:
        return 'Salaire';
      case TransactionCategory.freelance:
        return 'Freelance';
      case TransactionCategory.investment:
        return 'Investissement';
      case TransactionCategory.gift:
        return 'Cadeau';
      case TransactionCategory.otherIncome:
        return 'Autre revenu';
      case TransactionCategory.food:
        return 'Alimentation';
      case TransactionCategory.transport:
        return 'Transport';
      case TransactionCategory.housing:
        return 'Logement';
      case TransactionCategory.health:
        return 'Santé';
      case TransactionCategory.entertainment:
        return 'Loisirs';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.education:
        return 'Éducation';
      case TransactionCategory.utilities:
        return 'Factures';
      case TransactionCategory.otherExpense:
        return 'Autre dépense';
    }
  }

  String get icon {
    switch (this) {
      case TransactionCategory.salary:
        return '💼';
      case TransactionCategory.freelance:
        return '💻';
      case TransactionCategory.investment:
        return '📈';
      case TransactionCategory.gift:
        return '🎁';
      case TransactionCategory.otherIncome:
        return '💰';
      case TransactionCategory.food:
        return '🍔';
      case TransactionCategory.transport:
        return '🚗';
      case TransactionCategory.housing:
        return '🏠';
      case TransactionCategory.health:
        return '🏥';
      case TransactionCategory.entertainment:
        return '🎮';
      case TransactionCategory.shopping:
        return '🛍️';
      case TransactionCategory.education:
        return '📚';
      case TransactionCategory.utilities:
        return '⚡';
      case TransactionCategory.otherExpense:
        return '💸';
    }
  }

  TransactionType get type {
    if ([
      TransactionCategory.salary,
      TransactionCategory.freelance,
      TransactionCategory.investment,
      TransactionCategory.gift,
      TransactionCategory.otherIncome,
    ].contains(this)) {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }
}

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String? note;
  final String userId;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.index,
      'category': category.index,
      'date': date.toIso8601String(),
      'note': note,
      'userId': userId,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      title: map['title'],
      amount: map['amount'],
      type: TransactionType.values[map['type']],
      category: TransactionCategory.values[map['category']],
      date: DateTime.parse(map['date']),
      note: map['note'],
      userId: map['userId'],
    );
  }

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    TransactionCategory? category,
    DateTime? date,
    String? note,
    String? userId,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      userId: userId ?? this.userId,
    );
  }
}
