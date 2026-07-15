/// screens/detail_screen.dart
/// ===========================
/// Halaman detail satu menu rekomendasi MBG.

import 'package:flutter/material.dart';
import '../api_service.dart';

class DetailScreen extends StatelessWidget {
  final RekomendasiMenu menu;

  const DetailScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    final isLayak = menu.status.toLowerCase() == 'layak';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Makanan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      menu.namaMenu,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isLayak ? Colors.green[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isLayak ? '✓ Layak' : '✗ Tidak Layak',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isLayak ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Komposisi Menu ───────────────────────────────────────
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Komposisi Menu',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    _buildInfoRow(Icons.rice_bowl, 'Makanan Berat', menu.makananBerat),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.cake, 'Dessert / Buah', menu.dessert),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Kandungan Gizi ───────────────────────────────────────
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Kandungan Gizi',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const Divider(),
                    _buildGiziRow('Energi', '${menu.energi.toStringAsFixed(1)} kkal', Colors.orange),
                    _buildGiziRow('Protein', '${menu.protein.toStringAsFixed(1)} g', Colors.blue),
                    _buildGiziRow('Lemak', '${menu.lemak.toStringAsFixed(1)} g', Colors.red),
                    _buildGiziRow('Karbohidrat', '${menu.karbohidrat.toStringAsFixed(1)} g', Colors.purple),
                    _buildGiziRow('Serat', '${menu.serat.toStringAsFixed(1)} g', Colors.teal),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 2),
            Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  Widget _buildGiziRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
