# 💰 FinanceMe – Application de Gestion Financière

> Mini-Projet Flutter – 2ème Année Cycle Ingénieur |ENSA Tanger |Développement mobile| 2025/2026

---

## 📱 Description

FinanceMe est une application mobile de gestion financière personnelle développée avec Flutter. Elle permet aux utilisateurs de suivre leurs revenus et dépenses, gérer des budgets mensuels, et visualiser leurs habitudes financières à travers des statistiques détaillées.

---

## ✅ Fonctionnalités

### Obligatoires
- 🔐 **Authentification** – Inscription et connexion sécurisées (SHA-256)
- 🧭 **Navigation** – 4 onglets : Accueil, Transactions, Statistiques, Profil
- 📋 **CRUD complet** – Ajouter, lire, modifier, supprimer des transactions
- 📝 **Formulaires** – Avec validation complète des champs
- 💾 **Stockage local** – SQLite pour les données, SharedPreferences pour la session
- 📱 **Interface responsive** – Adaptée mobile
- 🏗️ **Architecture MVC** strictement respectée
- 🎨 **Design personnalisé** – Thème vert/sombre, icônes, animations

### Avancées
- 🌙 **Dark Mode** – Bascule clair/sombre persistante
- 📊 **Graphiques** – Bar chart (6 mois) + Pie chart (catégories)
- 🎯 **Budgets** – Limites par catégorie avec alertes visuelles
- 🔍 **Recherche & filtres** – Dans la liste des transactions
- 💱 **Multi-devises** – MAD, EUR, USD, GBP

---

## 🏗️ Architecture MVC

```
lib/
├── models/                    # M – Données & logique métier
│   ├── user_model.dart
│   ├── transaction_model.dart
│   └── budget_model.dart
│
├── controllers/               # C – Logique applicative
│   ├── auth_controller.dart
│   ├── transaction_controller.dart
│   ├── budget_controller.dart
│   └── theme_controller.dart
│
├── views/                     # V – Interface utilisateur
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── home_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── add_transaction_screen.dart
│   │   ├── statistics_screen.dart
│   │   ├── profile_screen.dart
│   │   └── budgets_screen.dart
│   └── widgets/
│       └── transaction_tile.dart
│
└── utils/                     # Utilitaires
    ├── database_helper.dart   # SQLite helper
    └── app_theme.dart         # Thème & constantes
```

---

## 🛠️ Technologies utilisées

| Technologie | Usage |
|-------------|-------|
| Flutter 3.x | Framework mobile |
| Dart | Langage de programmation |
| SQLite (sqflite) | Base de données locale |
| SharedPreferences | Persistance session & thème |
| Provider | Gestion d'état (MVC Controllers) |
| fl_chart | Graphiques (bar, pie) |
| google_fonts | Typographie (Poppins) |
| intl | Formatage dates & nombres |
| uuid | Génération d'identifiants |
| crypto | Hachage SHA-256 des mots de passe |

---

## 🚀 Installation & Exécution

### Prérequis

- Flutter SDK ≥ 3.0.0
- Dart SDK ≥ 3.0.0
- Android Studio 
- Un émulateur Android

### Étapes

```bash
# 1. Cloner le dépôt
git clone https://github.com/ikrammalki05/finance_manager.git
cd finance_manager

# 2. Installer les dépendances
flutter pub get

# 3. Lancer l'application
flutter run

# Pour un build de release Android
flutter build apk --release
```

---




Projet réalisé par MALKI Ikram dans le cadre du cours de Développement Mobile – ENSA Tanger
