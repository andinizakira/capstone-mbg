/// screens/sign_up_screen.dart
/// ============================
/// Halaman registrasi akun siswa baru.

import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _namaCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _confPassCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfPass = true;
  bool _agree       = false;
  bool _loading     = false;

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
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confPassCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passCtrl.text != _confPassCtrl.text) {
      _showSnack('Password dan Konfirmasi Password tidak cocok', isError: true);
      return;
    }
    
    if (!_agree) {
      _showSnack('Centang Terms of Use terlebih dahulu', isError: true);
      return;
    }
    setState(() => _loading = true);

    try {
      final result = await AuthService.register(
          _namaCtrl.text.trim(),
          _emailCtrl.text.trim(),
          _passCtrl.text);

      if (!mounted) return;

      if (result['status'] == 'success') {
        _showSnack('Registrasi berhasil! Silakan login.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } else {
        _showSnack(result['message'] ?? 'Registrasi gagal', isError: true);
      }
    } catch (e) {
      _showSnack('Gagal terhubung ke server', isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? const Color(0xFFEF5350) : const Color(0xFF4CAF50),
      behavior: SnackBarBehavior.floating,
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

                  // ── Judul ──────────────────────────────────────────────
                  const Center(
                    child: Text('Sign Up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text('Buat akun siswa MBG',
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 14)),
                  ),
                  const SizedBox(height: 36),

                  // ── Field Nama ─────────────────────────────────────────
                  _buildLabel('Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _namaCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('Nama lengkap', Icons.person_outline),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                  ),
                  const SizedBox(height: 18),

                  // ── Field Email ────────────────────────────────────────
                  _buildLabel('Email'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:  _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco('contoh@email.com', Icons.email_outlined),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                      if (!v.contains('@')) return 'Email tidak valid';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Field Password ─────────────────────────────────────
                  _buildLabel('Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:   _passCtrl,
                    obscureText:  _obscurePass,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDeco(
                      'Min. 6 karakter',
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
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password wajib diisi';
                      if (v.length < 6) return 'Password minimal 6 karakter';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // ── Field Confirm Password ─────────────────────────────
                  _buildLabel('Konfirmasi Password'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller:   _confPassCtrl,
                    obscureText:  _obscureConfPass,
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
                      if (v == null || v.isEmpty) return 'Konfirmasi password wajib diisi';
                      if (v != _passCtrl.text) return 'Password tidak sama';
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Terms Checkbox ─────────────────────────────────────
                  Row(
                    children: [
                      Checkbox(
                        value:    _agree,
                        onChanged: (v) => setState(() => _agree = v ?? false),
                        fillColor: MaterialStateProperty.resolveWith((s) =>
                            s.contains(MaterialState.selected)
                                ? const Color(0xFF4CAF50)
                                : Colors.transparent),
                        side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4)),
                      ),
                      Text('I agree to the ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 13)),
                      const Text('Terms of Use',
                          style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ── Tombol Sign Up ─────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _onSignUp,
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
                          : const Text('Registrasi',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // ── Link ke Login ──────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen())),
                      child: RichText(
                        text: TextSpan(
                          text: 'Sudah punya akun? ',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14),
                          children: const [
                            TextSpan(
                              text: 'Login',
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

  InputDecoration _inputDeco(String hint, IconData icon,
      {Widget? suffix}) {
    return InputDecoration(
      hintText:    hint,
      hintStyle:   TextStyle(color: Colors.white.withOpacity(0.3)),
      prefixIcon:  Icon(icon, color: const Color(0xFF4CAF50), size: 20),
      suffixIcon:  suffix,
      filled:      true,
      fillColor:   const Color(0xFF1C2128),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border:         OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
      enabledBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: Colors.white.withOpacity(0.08))),
      focusedBorder:  OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFF4CAF50), width: 1.5)),
      errorBorder:    OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFEF5350), width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
              color: Color(0xFFEF5350), width: 1.5)),
      errorStyle: const TextStyle(color: Color(0xFFEF5350)),
    );
  }
}
