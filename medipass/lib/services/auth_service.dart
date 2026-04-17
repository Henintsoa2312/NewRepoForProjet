import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String _baseUrl = 'http://10.0.2.2:3000/api';
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'user_email';
  static const _sessionKey = 'rememberSession'; // Clé pour la session

  // ... (register et login ne changent pas) ...
  Future<Map<String, dynamic>> register({
    required String nom,
    required String prenom,
    required DateTime dateNaissance,
    required String sexe,
    required String telephone,
    required String email,
    required String password,
  }) async {
    final String url = '$_baseUrl/auth/register';
    try {
      final String formattedDate =
          "${dateNaissance.year.toString().padLeft(4, '0')}-"
          "${dateNaissance.month.toString().padLeft(2, '0')}-"
          "${dateNaissance.day.toString().padLeft(2, '0')}";

      final requestBody = {
        'nom': nom.trim(),
        'prenom': prenom.trim(),
        'dateNaissance': formattedDate,
        'sexe': sexe,
        'telephone': telephone.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      };

      final response = await http
          .post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(requestBody),
      )
          .timeout(const Duration(seconds: 20));

      final decodedBody = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {
          'success': true,
          'message': decodedBody['message'] ?? 'Inscription réussie.',
        };
      } else {
        return {
          'success': false,
          'message': decodedBody['message'] ?? 'Erreur du serveur.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Une erreur réseau est survenue: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final String url = '$_baseUrl/auth/login';
    try {
      final requestBody = {
        'email': email.trim().toLowerCase(),
        'password': password,
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode(requestBody),
      ).timeout(const Duration(seconds: 20));

      final decodedBody = json.decode(response.body);

      if (response.statusCode == 200 && decodedBody.containsKey('token')) {
        await _storage.write(key: _tokenKey, value: decodedBody['token']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_emailKey, email.trim().toLowerCase());

        return {
          'success': true,
          'message': decodedBody['message'] ?? 'Connexion réussie.',
        };
      } else {
        return {
          'success': false,
          'message': decodedBody['message'] ?? 'Email ou mot de passe incorrect.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Une erreur réseau est survenue: ${e.toString()}'};
    }
  }

  Future<String?> generateShareCode() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) throw Exception('Utilisateur non authentifié.');

    final String url = '$_baseUrl/secure/generate-code';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 201) {
        final decodedBody = json.decode(response.body);
        return decodedBody['code'];
      } else {
        throw Exception('Erreur du serveur lors de la génération du code (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur réseau: ${e.toString()}');
    }
  }

  // LOGIQUE DE DÉCONNEXION MODIFIÉE POUR CONSERVER LE THÈME
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Effacer le token de sécurité
    await _storage.delete(key: _tokenKey);
    
    // 2. Effacer uniquement les données de session des préférences
    await prefs.remove(_emailKey);
    await prefs.remove(_sessionKey);

    print('AuthService: Déconnexion terminée. Les préférences de thème sont conservées.');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }
}
