/// screens/onboarding_screen.dart
/// ================================
/// Halaman onboarding yang tampil saat pertama kali membuka aplikasi.
/// Menampilkan 3 slide pengenalan fitur MBG.
/// Setelah selesai, flag disimpan di SharedPreferences agar tidak muncul lagi.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = [
    _OnboardingData(
      icon: Icons.restaurant_menu_rounded,
      title: 'Selamat Datang di MBG',
      subtitle: 'Sistem Rekomendasi Menu Makan Bergizi Gratis',
      description:
          'Dapatkan rekomendasi menu makanan bergizi yang disesuaikan '
          'dengan kebutuhan gizi harian berdasarkan umur dan jenis kelamin kamu.',
      color: const Color(0xFF4CAF50),
    ),
    _OnboardingData(
      icon: Icons.auto_awesome_rounded,
      title: 'Rekomendasi Cerdas',
      subtitle: 'Didukung Algoritma KNN & Naive Bayes',
      description:
          'Algoritma machine learning menganalisis data nutrisi dari TKPI Kemenkes '
          'dan memberikan rekomendasi menu paling sesuai untuk kamu.',
      color: const Color(0xFF2196F3),
    ),
    _OnboardingData(
      icon: Icons.insights_rounded,
      title: 'Pantau Riwayat Gizi',
      subtitle: 'Lihat Histori Rekomendasi Kamu',
      description:
          'Setiap rekomendasi tersimpan otomatis. Pantau pola makan bergizi '
          'dan pastikan kebutuhan nutrisi harian kamu selalu terpenuhi.',
      color: const Color(0xFFFF9800),
    ),
  ];

  void _onPageChanged(int index) {
    setState(() => _currentPage = index);
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar: Step + Lewati ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 12, 0),
              child: Row(
                children: [
                  Text(
                    '${_currentPage + 1} / ${_pages.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: Text(
                      'Lewati',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── PageView ──────────────────────────────────────────────
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: data.color.withOpacity(0.15),
                          ),
                          child: Icon(
                            data.icon,
                            color: data.color,
                            size: 44,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Title
                        Text(
                          data.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),

                        // Subtitle
                        Text(
                          data.subtitle,
                          style: TextStyle(
                            color: data.color,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),

                        // Description
                        Text(
                          data.description,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 14,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Bottom: Dots + Button ─────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 0, 28, 24),
              child: Column(
                children: [
                  // Dot indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.white.withOpacity(0.15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Mulai Sekarang'
                            : 'Lanjut',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data model ──────────────────────────────────────────────────────────────
class _OnboardingData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final Color color;

  const _OnboardingData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.color,
  });
}
