/// screens/login_screen.dart
/// ==========================
/// Halaman login untuk siswa dan admin.
/// Role terdeteksi dari JWT — admin diarahkan ke web, siswa ke InputScreen.

import 'package:flutter/material.dart';
import 'sign_up_screen.dart';
import '../services/auth_service.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _obscurePass     = true;
  bool _obscureConfPass = true;
  bool _loading         = false;

  late final AnimationController _animCtrl;
  late final Animation<double>   _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passCtrl.text != _confPassCtrl.text) {
      _showSnack('Password dan Confirm Password tidak cocok', isError: true);
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await AuthService.login(
          _emailCtrl.text.trim(), _passCtrl.text);

      if (!mounted) return;

      if (result['status'] == 'success') {
        final role = result['data']['user']['role'] as String;

        if (role == 'siswa') {
          // Arahkan siswa ke MainScreen (ada bottom nav: Home, History, Profile)
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainScreen()),
          );
        } else {
          // Admin tidak bisa login dari mobile
          await AuthService.clearSession();
          _showSnack(
            'Akun admin hanya dapat diakses melalui Web Admin.',
            isError: true,
          );
        }
      } else {
        _showSnack(result['message'] ?? 'Login gagal', isError: true);
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg),
      backgroundColor: isError ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Logo ───────────────────────────────────────────────
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.4),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Icon(Icons.restaurant_menu,
                          color: Colors.white, size: 36),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Center(
                    child: Text('Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Masuk ke akun MBG Anda',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 36),

                  // ── Email ──────────────────────────────────────────────
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:   _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration:   _inputDeco('contoh@email.com', Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Password ───────────────────────────────────────────
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:  _passCtrl,
                    obscureText: _obscurePass,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco(
                      'Password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Confirm Password ───────────────────────────────────
                  _buildLabel('Konfirmasi Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:  _confPassCtrl,
                    obscureText: _obscureConfPass,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco(
                      'Ketik ulang password',
                      Icons.lock_outline,
                      suffix: IconButton(
                        icon: Icon(
                          _obscureConfPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfPass = !_obscureConfPass),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirm password wajib diisi';
                      if (v != _passCtrl.text) return 'Password tidak sama';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Tombol Login ───────────────────────────────────────
                  SizedBox(
                    width:  double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: _loading
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : const Text('Login',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Link ke Sign Up ────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const SignUpScreen())),
                      child: RichText(
                        text: TextSpan(
                          text: 'Belum punya akun? ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14),
                          children: const [
                            TextSpan(
                              text: 'Daftar',
                              style: TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) => Text(label,
      style: TextStyle(
          color: Colors.white.withOpacity(0.8),
          fontSize: 13.5,
          fontWeight: FontWeight.w600));

  InputDecoration _inputDeco(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText:    hint,
      hintStyle:   TextStyle(color: Colors.white.withOpacity(0.3)),
      prefixIcon:  Icon(icon, color: const Color(0xFF4CAF50), size: 20),
      suffixIcon:  suffix,
      filled:      true,
      fillColor:   const Color(0xFF1C2128),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4CAF50), width: 1.5)),
      errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFFEF5350), width: 1.5)),
      errorStyle: const TextStyle(color: Color(0xFFEF5350)),
    );
  }
}
