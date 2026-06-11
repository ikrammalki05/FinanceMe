// lib/controllers/auth_controller.dart

import 'dart:convert';
import 'package:crypto/crypto.dart' show sha256;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../utils/database_helper.dart';

class AuthController extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  final DatabaseHelper _db = DatabaseHelper();
  final Uuid _uuid = const Uuid();

  // 🔐 AUTO LOGIN SAFE
  Future<void> checkAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');

      if (userId == null) return;

      final user = await _db.getUserById(userId);

      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("checkAutoLogin error: $e");
    }
  }

  // 🔑 HASH PASSWORD
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // 🟢 REGISTER
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final cleanEmail = email.toLowerCase().trim();

      final existing = await _db.getUserByEmail(cleanEmail);
      if (existing != null) {
        _setError("Cet email est déjà utilisé.");
        return false;
      }

      final user = UserModel(
        id: _uuid.v4(),
        name: name.trim(),
        email: cleanEmail,
        passwordHash: _hashPassword(password),
        createdAt: DateTime.now(),
      );

      await _db.insertUser(user);

      _currentUser = user;
      await _saveSession(user.id);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Erreur lors de l'inscription.");
      return false;
    }
  }

  // 🔵 LOGIN
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      final cleanEmail = email.toLowerCase().trim();

      final user = await _db.getUserByEmail(cleanEmail);

      if (user == null) {
        _setError("Email ou mot de passe incorrect.");
        return false;
      }

      if (user.passwordHash != _hashPassword(password)) {
        _setError("Email ou mot de passe incorrect.");
        return false;
      }

      _currentUser = user;
      await _saveSession(user.id);

      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError("Erreur lors de la connexion.");
      return false;
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');

      _currentUser = null;
      notifyListeners();
    } catch (e) {
      debugPrint("Logout error: $e");
    }
  }

  // ✏️ UPDATE PROFILE
  Future<bool> updateProfile({
    required String name,
    required String currency,
    required double monthlyBudget,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updated = _currentUser!.copyWith(
        name: name.trim(),
        currency: currency,
        monthlyBudget: monthlyBudget,
      );

      await _db.updateUser(updated);

      _currentUser = updated;
      notifyListeners();

      return true;
    } catch (e) {
      debugPrint("Update profile error: $e");
      return false;
    }
  }

  // 💾 SAVE SESSION
  Future<void> _saveSession(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
  }

  // ⚙️ STATE HELPERS
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}