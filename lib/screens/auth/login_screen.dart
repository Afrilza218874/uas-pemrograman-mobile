import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (!mounted) return;
    if (ok) Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)]),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: const Color(0xFFFF6B6B).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                      ),
                      child: const Icon(Icons.newspaper_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text('Selamat Datang!', style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
                    const SizedBox(height: 6),
                    Text('Login untuk melanjutkan ke NewsClip', style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF8892A4))),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(ctrl: _emailCtrl, label: 'Email', icon: Icons.email_outlined, keyboard: TextInputType.emailAddress,
                      validator: (v) { if (v == null || v.isEmpty) return 'Email wajib diisi'; if (!v.contains('@')) return 'Format email tidak valid'; return null; }),
                    const SizedBox(height: 16),
                    _field(ctrl: _passCtrl, label: 'Password', icon: Icons.lock_outline_rounded, obscure: _obscure,
                      suffix: IconButton(icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF8892A4), size: 20), onPressed: () => setState(() => _obscure = !_obscure)),
                      validator: (v) { if (v == null || v.isEmpty) return 'Password wajib diisi'; return null; }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => auth.error != null
                    ? Container(width: double.infinity, padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFFF6B6B).withOpacity(0.12), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.3))),
                        child: Text(auth.error!, style: GoogleFonts.outfit(fontSize: 13, color: const Color(0xFFFF6B6B))))
                    : const SizedBox.shrink(),
              ),
              const SizedBox(height: 28),
              Consumer<AuthProvider>(
                builder: (_, auth, __) => SizedBox(
                  width: double.infinity, height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B6B), foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    onPressed: auth.isLoading ? null : _login,
                    child: auth.isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                        : Text('Login', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Belum punya akun? ', style: GoogleFonts.outfit(color: const Color(0xFF8892A4), fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                    child: Text('Daftar sekarang', style: GoogleFonts.outfit(color: const Color(0xFFFF6B6B), fontSize: 14, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field({required TextEditingController ctrl, required String label, required IconData icon, TextInputType keyboard = TextInputType.text, bool obscure = false, Widget? suffix, String? Function(String?)? validator}) {
    return TextFormField(
      controller: ctrl, keyboardType: keyboard, obscureText: obscure,
      style: GoogleFonts.outfit(color: Colors.white, fontSize: 15),
      validator: validator,
      decoration: InputDecoration(
        labelText: label, labelStyle: GoogleFonts.outfit(color: const Color(0xFF8892A4)),
        prefixIcon: Icon(icon, color: const Color(0xFF8892A4), size: 20), suffixIcon: suffix,
        filled: true, fillColor: const Color(0xFF141824),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1E2640), width: 1)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5)),
        errorStyle: GoogleFonts.outfit(color: const Color(0xFFFF6B6B), fontSize: 12),
      ),
    );
  }
}
