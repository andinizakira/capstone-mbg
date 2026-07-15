/// result_screen.dart
/// ===================
/// Halaman hasil rekomendasi menu MBG.

import 'package:flutter/material.dart';
import 'api_service.dart';
import 'screens/detail_screen.dart';

class ResultScreen extends StatefulWidget {
  final int umur;
  final String jk;

  const ResultScreen({super.key, required this.umur, required this.jk});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late Future<HasilRekomendasi> _futureHasil;

  @override
  void initState() {
    super.initState();
    _futureHasil = ApiService.dapatkanRekomendasi(widget.umur, widget.jk);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MBG'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<HasilRekomendasi>(
        future: _futureHasil,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoading();
          }
          if (snapshot.hasError) {
            return _buildError(snapshot.error.toString());
          }
          return _buildResult(snapshot.data!);
        },
      ),
    );
  }

  // ── Loading ──────────────────────────────────────────────────────────
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Color(0xFF4CAF50)),
          SizedBox(height: 16),
          Text('Memproses data...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  // ── Error ────────────────────────────────────────────────────────────
  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => setState(() {
                _futureHasil = ApiService.dapatkanRekomendasi(widget.umur, widget.jk);
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hasil ────────────────────────────────────────────────────────────
  Widget _buildResult(HasilRekomendasi hasil) {
    final jkLabel = widget.jk == 'L' ? 'Laki-laki' : 'Perempuan';

    return Column(
      children: [
        // Header info
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1A1A1A),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Hasil Rekomendasi Makanan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'Umur: ${widget.umur} tahun  |  Jenis Kelamin: $jkLabel',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.white.withOpacity(0.08)),

        // List menu
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: hasil.rekomendasi.length,
            itemBuilder: (context, i) {
              return _buildMenuCard(hasil.rekomendasi[i], i);
            },
          ),
        ),

        // Tombol kembali
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF50),
                side: const BorderSide(color: Color(0xFF4CAF50)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Input Data Baru'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuCard(RekomendasiMenu menu, int index) {
    final isLayak = menu.status.toLowerCase() == 'layak';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(menu: menu)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: nomor + nama + status
              Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isLayak ? Colors.green[50] : Colors.red[50],
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: isLayak ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      menu.namaMenu,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isLayak ? Colors.green[50] : Colors.red[50],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLayak ? Icons.check_circle : Icons.cancel,
                          size: 14,
                          color: isLayak ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          menu.status,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLayak ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Info makanan
              Text(
                'Makanan Berat: ${menu.makananBerat}',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(height: 2),
              Text(
                'Dessert: ${menu.dessert}',
                style: TextStyle(fontSize: 13, color: Colors.grey[400]),
              ),
              const SizedBox(height: 10),

              // Info gizi singkat
              Row(
                children: [
                  _buildGiziBadge('${menu.energi.toInt()} kkal', Colors.orange),
                  const SizedBox(width: 6),
                  _buildGiziBadge('P: ${menu.protein.toInt()}g', Colors.blue),
                  const SizedBox(width: 6),
                  _buildGiziBadge('L: ${menu.lemak.toInt()}g', Colors.red),
                  const SizedBox(width: 6),
                  _buildGiziBadge('KH: ${menu.karbohidrat.toInt()}g', Colors.purple),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey[400]),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGiziBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
