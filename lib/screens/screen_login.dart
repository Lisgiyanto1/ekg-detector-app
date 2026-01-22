import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_bloc.dart';
import 'package:flutter_ekg_detector/features/auth/auth_event.dart';
import 'package:flutter_ekg_detector/features/auth/auth_state.dart';
import 'package:flutter_ekg_detector/screens/screen_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool isLogin = false;
  bool _hasNavigated = false;

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    // Cek apakah keyboard sedang tampil
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    final characterAsset = isLogin
        ? 'assets/characterlogin.png'
        : 'assets/characterregister.png';

    return Scaffold(
      // resizeToAvoidBottomInset: true membiarkan scaffold menyesuaikan tinggi saat keyboard muncul
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: [0.1, 1.0],
            colors: [Color(0xFF0A607F), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              // ================= ERROR =================
              if (state is AuthError) {
                _showSnack(context, state.message, isError: true);
              }

              // ================= SUCCESS =================
              if (state is AuthAuthenticated && !_hasNavigated) {
                _hasNavigated = true;
                _showSnack(context, 'Login Berhasil', isError: false);
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  }
                });
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              return Form(
                key: _formKey,
                child: Column(
                  children: [
                    /// ================= CHARACTER =================
                    /// Menggunakan Expanded agar gambar fleksibel.
                    /// Saat keyboard muncul (isKeyboardVisible), flex gambar mengecil
                    /// agar area Form di bawah mendapat ruang lebih.
                    Expanded(
                      flex: isKeyboardVisible ? 2 : 4,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Transform.translate(
                            key: ValueKey(characterAsset),
                            offset: const Offset(-10, 20),
                            child: Image.asset(
                              characterAsset,
                              width: screen.width * 1.4,
                              // Hapus height fix, biarkan mengikuti parent
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// ================= FORM CARD =================
                    /// Expanded di sini SANGAT PENTING.
                    /// Ini membuat Card putih mengambil sisa ruang layar yang tersedia.
                    /// ScrollView diletakkan DI DALAM Card ini.
                    Expanded(
                      flex: isKeyboardVisible
                          ? 3
                          : 0, // Prioritas ruang saat keyboard muncul
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: SingleChildScrollView(
                          // PERBAIKAN: Hapus viewInsets.bottom di sini karena menyebabkan double padding
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLogin ? 'Login' : 'Register',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),

                              if (!isLogin)
                                _input(
                                  controller: _usernameController,
                                  icon: Icons.person_outline,
                                  hint: 'Username',
                                  validator: (v) => v!.isEmpty
                                      ? 'Username wajib diisi'
                                      : null,
                                ),

                              if (!isLogin) const SizedBox(height: 14),

                              _input(
                                controller: _emailController,
                                icon: Icons.email_outlined,
                                hint: 'Email',
                                validator: _validateEmail,
                              ),

                              const SizedBox(height: 14),

                              _input(
                                controller: _passwordController,
                                icon: Icons.lock_outline,
                                hint: 'Password',
                                obscure: true,
                                validator: _validatePassword,
                              ),

                              const SizedBox(height: 22),

                              /// TOMBOL LOGIN / SIGN UP
                              ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (!_formKey.currentState!
                                            .validate()) {
                                          _showError(context);
                                          return;
                                        }

                                        if (isLogin) {
                                          context.read<AuthBloc>().add(
                                            LoginWithEmail(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                        } else {
                                          context.read<AuthBloc>().add(
                                            RegisterWithEmail(
                                              email: _emailController.text
                                                  .trim(),
                                              password:
                                                  _passwordController.text,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    35,
                                    186,
                                    197,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        isLogin ? 'Login' : 'Sign Up',
                                        style: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                              ),

                              const SizedBox(height: 20),

                              /// ===== DIVIDER OR WITH =====
                              Row(
                                children: [
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey[400],
                                      thickness: 0.5,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Text(
                                      "Or with",
                                      style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Divider(
                                      color: Colors.grey[400],
                                      thickness: 0.5,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              /// TOMBOL GOOGLE
                              OutlinedButton.icon(
                                onPressed: () => context.read<AuthBloc>().add(
                                  LoginWithGoogle(),
                                ),
                                icon: SvgPicture.asset(
                                  'assets/google.svg',
                                  height: 18,
                                ),
                                label: const Text(
                                  'Google',
                                  style: TextStyle(color: Colors.black87),
                                ),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  side: BorderSide(color: Colors.grey.shade300),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              /// TOGGLE LOGIN/REGISTER TEXT
                              TextButton(
                                onPressed: () =>
                                    setState(() => isLogin = !isLogin),
                                child: RichText(
                                  text: TextSpan(
                                    text: isLogin
                                        ? 'Belum punya akun? '
                                        : 'Sudah punya akun? ',
                                    style: TextStyle(color: Colors.grey[600]),
                                    children: [
                                      TextSpan(
                                        text: isLogin ? 'Register' : 'Login',
                                        style: const TextStyle(
                                          color: Color(0xFF0A607F),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// ================= VALIDATORS & INPUT =================

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';
    // Contoh regex: Min 6 char, butuh huruf besar, kecil & angka
    final passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$');
    if (!passwordRegex.hasMatch(value)) {
      return 'Min 6 kar: Huruf besar, kecil & angka';
    }
    return null;
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua field wajib diisi dengan benar'),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    String? Function(String?)? validator,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      // Autovalidate agar user langsung tahu jika salah
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF23BAC5), width: 1.5),
        ),
      ),
    );
  }
}

void _showSnack(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError
          ? Colors.redAccent
          : const Color.fromARGB(255, 35, 197, 103),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
  );
}
