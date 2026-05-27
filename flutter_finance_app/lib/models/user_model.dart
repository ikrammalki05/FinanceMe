// lib/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String currency;
  final double monthlyBudget;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    this.currency = 'MAD',
    this.monthlyBudget = 0.0,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'passwordHash': passwordHash,
      'currency': currency,
      'monthlyBudget': monthlyBudget,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      passwordHash: map['passwordHash'],
      currency: map['currency'] ?? 'MAD',
      monthlyBudget: map['monthlyBudget'] ?? 0.0,
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? passwordHash,
    String? currency,
    double? monthlyBudget,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      currency: currency ?? this.currency,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
