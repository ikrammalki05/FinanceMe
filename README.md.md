# 💰 FinanceMe – Application de Gestion Financière

**Mini-Projet Flutter – 2ème Année Cycle Ingénieur**  
**ENSA Tanger | Développement Mobile | 2025/2026**

---

## 📱 Description

**FinanceMe** est une application mobile de gestion financière personnelle développée avec **Flutter**.

Elle permet aux utilisateurs de gérer leurs finances quotidiennes à travers :
- Le suivi des revenus et dépenses
- La gestion des budgets
- La visualisation des statistiques financières
- La sauvegarde locale et la synchronisation via API

L'application a été développée selon une architecture **MVC** et intègre différentes méthodes de stockage afin de comparer l'utilisation d'une base locale et des services web.

---

# ✅ Fonctionnalités

## 🔐 Authentification
- Inscription et connexion utilisateur
- Sécurisation des mots de passe avec **SHA-256**
- Gestion persistante de la session

## 💳 Gestion financière
- Ajout des transactions
- Consultation de l'historique
- Modification et suppression des transactions
- Validation complète des formulaires
- Gestion des catégories de dépenses et revenus

## 📊 Statistiques
- Graphiques financiers :
  - Bar chart pour l'évolution mensuelle
  - Pie chart pour la répartition des catégories
- Analyse des habitudes financières

## 🎯 Budgets
- Création de budgets par catégorie
- Suivi des limites
- Alertes visuelles en cas de dépassement

## 🎨 Interface utilisateur
- Design personnalisé
- Mode clair / sombre
- Navigation par onglets
- Interface responsive adaptée aux mobiles

## 🔍 Recherche et filtres
- Recherche des transactions
- Filtrage par catégorie
- Tri des données

## 💱 Multi-devises
Support de plusieurs devises :
- MAD
- EUR
- USD
- GBP

---

# 📚 Intégration du TP API Flutter

Le projet intègre les trois approches de gestion des données étudiées dans le TP :

| Partie | Technologie utilisée | Objectif |
|-------|---------------------|----------|
| Partie 1 | SQLite | Gestion des données en local |
| Partie 2 | JSON Server | Consommation d'une API locale |
| Partie 3 | API Cloud | Communication avec un service distant |

Un écran **"Source de Données"** permet de visualiser et tester les différentes méthodes.

---

# 🏗️ Architecture MVC

Le projet respecte l'architecture **Model - View - Controller** :
lib/
│
├── models/
│ ├── user_model.dart
│ ├── transaction_model.dart
│ └── budget_model.dart
│
├── controllers/
│ ├── auth_controller.dart
│ ├── transaction_controller.dart
│ ├── budget_controller.dart
│ ├── theme_controller.dart
│ └── data_source_controller.dart
│
├── views/
│ ├── screens/
│ │ ├── login_screen.dart
│ │ ├── register_screen.dart
│ │ ├── home_screen.dart
│ │ ├── dashboard_screen.dart
│ │ ├── transactions_screen.dart
│ │ ├── add_transaction_screen.dart
│ │ ├── statistics_screen.dart
│ │ ├── profile_screen.dart
│ │ ├── budgets_screen.dart
│ │ └── data_source_screen.dart
│ │
│ └── widgets/
│ └── transaction_tile.dart
│
├── services/
│ ├── api_service.dart
│ └── transaction_http_service.dart
│
└── utils/
├── database_helper.dart
└── app_theme.dart

---

# 🛠️ Technologies utilisées

| Technologie | Utilisation |
|------------|-------------|
| Flutter | Framework mobile |
| Dart | Langage de programmation |
| SQLite | Stockage local |
| SharedPreferences | Gestion de session et préférences |
| Provider | Gestion d'état |
| HTTP | Communication avec les APIs |
| JSON Server | Simulation d'une API REST |
| fl_chart | Création des graphiques |
| google_fonts | Gestion des polices |
| intl | Formatage des dates et nombres |
| uuid | Génération des identifiants |
| crypto | Chiffrement SHA-256 |

---

# 🔄 Gestion des données

L'application utilise un système permettant de basculer entre plusieurs sources de données :

### Stockage local
- Utilisation de SQLite
- Accès via `DatabaseHelper`

### API REST
- Communication HTTP
- Sérialisation et désérialisation JSON
- Gestion des opérations CRUD

Les modèles de données ont été adaptés pour fonctionner avec les deux types de stockage.

---

# 📡 Opérations API disponibles

Les services API permettent :

- Récupération des transactions
- Ajout d'une transaction
- Modification d'une transaction
- Suppression d'une transaction
- Gestion des utilisateurs
- Gestion des budgets

---

# 🚀 Installation & Exécution

## Prérequis

- Flutter SDK
- Dart SDK
- Android Studio
- Émulateur ou appareil mobile

## Installation

```bash
git clone https://github.com/ikrammalki05/finance_manager.git

cd finance_manager

flutter pub get

Lancement:
flutter run

Génération APK:
flutter build apk --release