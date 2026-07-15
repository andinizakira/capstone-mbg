/// api_service.dart
/// =================
/// Service layer untuk komunikasi HTTP ke Flask Backend API.
/// Menggunakan package 'http' untuk request POST ke /api/rekomendasi.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'services/auth_service.dart';
import 'config.dart';

// ---------------------------------------------------------------------------
// Model Data: RekomendasiMenu
// ---------------------------------------------------------------------------

class RekomendasiMenu {
  final int? id;
  final String namaMenu;
  final String makananBerat;
  final String dessert;
  final double energi;
  final double protein;
  final double lemak;
  final double karbohidrat;
  final double serat;
  final String status;
  final double jarak;

  const RekomendasiMenu({
    this.id,
    required this.namaMenu,
    required this.makananBerat,
    required this.dessert,
    required this.energi,
    required this.protein,
    required this.lemak,
    required this.karbohidrat,
    required this.serat,
    required this.status,
    required this.jarak,
  });

  factory RekomendasiMenu.fromJson(Map<String, dynamic> json) {
    return RekomendasiMenu(
      id:           json['id'] as int?,
      namaMenu:     json['nama_menu']     as String? ?? '-',
      makananBerat: json['makanan_berat'] as String? ?? '-',
      dessert:      json['dessert']       as String? ?? '-',
      energi:       (json['energi']       as num).toDouble(),
      protein:      (json['protein']      as num).toDouble(),
      lemak:        (json['lemak']        as num).toDouble(),
      karbohidrat:  (json['karbohidrat']  as num).toDouble(),
      serat:        (json['serat']        as num).toDouble(),
      status:       json['status']        as String? ?? '-',
      jarak:        (json['jarak']        as num).toDouble(),
    );
  }
}

class AkgTarget {
  final double energi;
  final double protein;
  final double lemak;
  final double karbohidrat;
  final double serat;

  const AkgTarget({
    required this.energi,
    required this.protein,
    required this.lemak,
    required this.karbohidrat,
    required this.serat,
  });

  factory AkgTarget.fromJson(Map<String, dynamic> json) {
    return AkgTarget(
      energi:      (json['energi']      as num).toDouble(),
      protein:     (json['protein']     as num).toDouble(),
      lemak:       (json['lemak']       as num).toDouble(),
      karbohidrat: (json['karbohidrat'] as num).toDouble(),
      serat:       (json['serat']       as num).toDouble(),
    );
  }
}

class HasilRekomendasi {
  final int umur;
  final String jenisKelamin;
  final AkgTarget akgTarget;
  final List<RekomendasiMenu> rekomendasi;

  const HasilRekomendasi({
    required this.umur,
    required this.jenisKelamin,
    required this.akgTarget,
    required this.rekomendasi,
  });

  factory HasilRekomendasi.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final input = data['input'] as Map<String, dynamic>;
    final rawList = data['rekomendasi'] as List<dynamic>;

    return HasilRekomendasi(
      umur:         input['umur'] as int,
      jenisKelamin: input['jenis_kelamin'] as String,
      akgTarget:    AkgTarget.fromJson(data['akg_target'] as Map<String, dynamic>),
      rekomendasi:  rawList
          .map((e) => RekomendasiMenu.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ---------------------------------------------------------------------------
// API Service
// ---------------------------------------------------------------------------

class ApiService {
  static String get _baseUrl => AppConfig.baseUrl;
  static const Duration _timeout = Duration(seconds: 30);

  /// Helper untuk mendapatkan JWT header
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept':       'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<HasilRekomendasi> dapatkanRekomendasi(int umur, String jk) async {
    final uri = Uri.parse('$_baseUrl/api/rekomendasi');

    try {
      final headers = await _getHeaders();
      final response = await http
          .post(
            uri,
            headers: headers,
            body: jsonEncode({'umur': umur, 'jenis_kelamin': jk}),
          )
          .timeout(_timeout);

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        return HasilRekomendasi.fromJson(decoded);
      } else {
        final pesan = decoded['message'] as String? ?? 'Terjadi kesalahan.';
        throw Exception('Error ${response.statusCode}: $pesan');
      }
    } on Exception {
      rethrow;
    }
  }
}
