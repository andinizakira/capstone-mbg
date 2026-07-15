/// screens/riwayat_screen.dart
/// ============================
/// Halaman riwayat rekomendasi menu siswa.

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import '../config.dart';
import 'detail_screen.dart';
import '../api_service.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  static String get _baseUrl => AppConfig.baseUrl;
  late Future<List<Map<String, dynamic>>> _futureRiwayat;

  @override
  void initState() {
    super.initState();
    _futureRiwayat = _fetchRiwayat();
  }

  Future<List<Map<String, dynamic>>> _fetchRiwayat() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('Sesi tidak ditemukan. Silakan login kembali.');

    final res = await http.get(
      Uri.parse('$_baseUrl/api/riwayat'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    ).timeout(const Duration(seconds: 20));

    final decoded = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      return (decoded['data'] as List)
          .map((e) => e as Map<String, dynamic>)
          .toList();
    }
    throw Exception(decoded['message'] ?? 'Gagal memuat riwayat');
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _futureRiwayat = _fetchRiwayat();
    });
    await _futureRiwayat.catchError((_) => <Map<String, dynamic>>[]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Menu'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: _handleRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF4CAF50),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureRiwayat,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      snapshot.error.toString().replaceAll('Exception: ', ''),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _handleRefresh,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final data = snapshot.data!;
            if (data.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('Belum ada riwayat', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    SizedBox(height: 4),
                    Text('Riwayat rekomendasi akan muncul di sini',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, i) {
                return _buildRiwayatCard(data[i]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildRiwayatCard(Map<String, dynamic> item) {
    final isLayak = (item['status'] as String? ?? '').toLowerCase() == 'layak';
    final umur = item['umur'] as int? ?? 0;
    final jk = (item['jenis_kelamin'] as String? ?? 'L') == 'L' ? 'Laki-laki' : 'Perempuan';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          final dummyMenu = RekomendasiMenu(
            namaMenu: item['nama_menu'] as String? ?? '-',
            makananBerat: item['makanan_berat'] as String? ?? '-',
            dessert: item['dessert'] as String? ?? '-',
            energi: (item['energi'] as num?)?.toDouble() ?? 0.0,
            protein: (item['protein'] as num?)?.toDouble() ?? 0.0,
            lemak: (item['lemak'] as num?)?.toDouble() ?? 0.0,
            karbohidrat: (item['karbohidrat'] as num?)?.toDouble() ?? 0.0,
            serat: (item['serat'] as num?)?.toDouble() ?? 0.0,
            status: item['status'] as String? ?? '-',
            jarak: 0.0,
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(menu: dummyMenu)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['tanggal'] as String? ?? '-',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                  Icon(
                    isLayak ? Icons.check_circle : Icons.cancel,
                    color: isLayak ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Nama menu
              Text(
                item['nama_menu'] as String? ?? '-',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '$umur tahun  •  $jk',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 6),

              // Energi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(item['energi'] as num?)?.toInt() ?? 0} kkal',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange,
                    ),
                  ),
                  Text(
                    'Detail →',
                    style: TextStyle(fontSize: 12, color: Colors.green[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
