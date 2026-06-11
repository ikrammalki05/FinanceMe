// lib/services/api_service.dart
// ─────────────────────────────────────────────────────────────────────────────
//  Service HTTP générique — Parties 2 et 3 du TP
//
//  PARTIE 2 → ApiConfig.localUrl  (json-server sur votre machine)
//  PARTIE 3 → ApiConfig.cloudUrl  (API déployée sur le Cloud)
// ─────────────────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// ─── Configuration des URLs ──────────────────────────────────────────────────
class ApiConfig {
  // ── Partie 2 : json-server local ─────────────────────────────────────────
  //  Émulateur Android  → 10.0.2.2  (alias de localhost)
  //  Émulateur iOS      → 127.0.0.1
  //  Appareil physique  → adresse IP de votre PC (ex: 192.168.1.100)
  static const String localUrl = 'http://10.0.2.2:3000';

  // ── Partie 3 : API Cloud ──────────────────────────────────────────────────
  //  Remplacez par l'URL de votre serveur (Railway, Render, Heroku, etc.)
  static const String cloudUrl = 'https://votre-api.railway.app';
}

// ─── Codes d'erreur HTTP ─────────────────────────────────────────────────────
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException(HTTP $statusCode): $message';
}

// ─── Service CRUD générique ──────────────────────────────────────────────────
class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({
    required this.baseUrl,
    http.Client? client,
  }) : _client = client ?? http.Client();

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  // ── GET /endpoint?userId=x ─────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getByUser(
      String endpoint, String userId) async {
    final uri = Uri.parse('$baseUrl/$endpoint')
        .replace(queryParameters: {'userId': userId});
    debugPrint('[API] GET $uri');

    try {
      final res = await _client.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      _checkStatus(res);
      final body = jsonDecode(res.body);
      if (body is List) return body.cast<Map<String, dynamic>>();
      throw const ApiException('La réponse n\'est pas une liste');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  // ── GET /endpoint ──────────────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> getAll(String endpoint) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint('[API] GET $uri');

    try {
      final res = await _client.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      _checkStatus(res);
      final body = jsonDecode(res.body);
      if (body is List) return body.cast<Map<String, dynamic>>();
      throw const ApiException('La réponse n\'est pas une liste');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  // ── GET /endpoint/:id ──────────────────────────────────────────────────
  Future<Map<String, dynamic>?> getById(
      String endpoint, String id) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$id');
    debugPrint('[API] GET $uri');

    try {
      final res = await _client.get(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      if (res.statusCode == 404) return null;
      _checkStatus(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  // ── POST /endpoint ─────────────────────────────────────────────────────
  Future<Map<String, dynamic>> create(
      String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint');
    debugPrint('[API] POST $uri');

    try {
      final res = await _client
          .post(uri, headers: _headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      _checkStatus(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  // ── PUT /endpoint/:id ──────────────────────────────────────────────────
  Future<Map<String, dynamic>> update(
      String endpoint, String id, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$id');
    debugPrint('[API] PUT $uri');

    try {
      final res = await _client
          .put(uri, headers: _headers, body: jsonEncode(data))
          .timeout(const Duration(seconds: 10));
      _checkStatus(res);
      return jsonDecode(res.body) as Map<String, dynamic>;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  // ── DELETE /endpoint/:id ───────────────────────────────────────────────
  Future<bool> delete(String endpoint, String id) async {
    final uri = Uri.parse('$baseUrl/$endpoint/$id');
    debugPrint('[API] DELETE $uri');

    try {
      final res = await _client.delete(uri, headers: _headers)
          .timeout(const Duration(seconds: 10));
      _checkStatus(res);
      return true;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur réseau : $e');
    }
  }

  void _checkStatus(http.Response res) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw ApiException(
        'HTTP ${res.statusCode}: ${res.reasonPhrase}',
        statusCode: res.statusCode,
      );
    }
  }

  void dispose() => _client.close();
}
