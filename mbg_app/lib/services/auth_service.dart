/// services/auth_service.dart
/// ============================
/// Layanan autentikasi: simpan/baca token JWT dan data user dari SharedPreferences.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class AuthService {
  static String get _baseUrl => AppConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 20);

  // ── Keys SharedPreferences ─────────────────────────────────────────────
  static const _keyToken  = 'jwt_token';
  static const _keyUser   = 'user_data';

  // ── Simpan token & data user ───────────────────────────────────────────
  static Future<void> saveSession(String token, Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
    await prefs.setString(_keyUser, jsonEncode(user));
  }

  // ── Baca token ─────────────────────────────────────────────────────────
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ── Baca data user ─────────────────────────────────────────────────────
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw   = prefs.getString(_keyUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Hapus sesi (logout) ────────────────────────────────────────────────
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
  }

  // ── Cek apakah sudah login ─────────────────────────────────────────────
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ── Register ───────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> register(
      String nama, String email, String password) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/auth/register'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'nama': nama, 'email': email, 'password': password}),
        )
        .timeout(_timeout);

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) {
      await saveSession(
        decoded['data']['token'] as String,
        decoded['data']['user']  as Map<String, dynamic>,
      );
    }
    return decoded;
  }

  // ── Login ──────────────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await http
        .post(
          Uri.parse('$_baseUrl/api/auth/login'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}),
        )
        .timeout(_timeout);

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await saveSession(
        decoded['data']['token'] as String,
        decoded['data']['user']  as Map<String, dynamic>,
      );
    }
    return decoded;
  }
}
