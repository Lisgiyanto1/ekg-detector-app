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
    final characterAsset = isLogin
        ? 'assets/characterlogin.png'
        : 'assets/characterregister.png';

    return Scaffold(
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

                _showSnack(context, 'Authentication success', isError: false);

                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
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
                    Expanded(
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
                              height: screen.height * 0.55,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// ================= FORM CARD =================
                    SingleChildScrollView(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                      ),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                validator: (v) =>
                                    v!.isEmpty ? 'Username wajib diisi' : null,
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

                            ElevatedButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState!.validate()) {
                                        _showError(context);
                                        return;
                                      }

                                      if (isLogin) {
                                        context.read<AuthBloc>().add(
                                          LoginWithEmail(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
                                          ),
                                        );
                                      } else {
                                        context.read<AuthBloc>().add(
                                          RegisterWithEmail(
                                            email: _emailController.text.trim(),
                                            password: _passwordController.text,
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
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    )
                                  : Text(
                                      isLogin ? 'Login' : 'Sign Up',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                            ),

                            const SizedBox(height: 18),

                            OutlinedButton.icon(
                              onPressed: () => context.read<AuthBloc>().add(
                                LoginWithGoogle(),
                              ),
                              icon: SvgPicture.asset(
                                'assets/google.svg',
                                height: 18,
                              ),
                              label: const Text('Google'),
                            ),

                            const SizedBox(height: 12),

                            TextButton(
                              onPressed: () =>
                                  setState(() => isLogin = !isLogin),
                              child: Text(
                                isLogin
                                    ? 'Belum punya akun? Register'
                                    : 'Sudah punya akun? Login',
                              ),
                            ),
                          ],
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

  /// ================= VALIDATORS =================

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email wajib diisi';

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) return 'Format email tidak valid';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password wajib diisi';

    final passwordRegex = RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$',
    );

    if (!passwordRegex.hasMatch(value)) {
      return 'Min 6 karakter, huruf besar, kecil, angka & simbol';
    }
    return null;
  }

  void _showError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua field wajib diisi dengan benar'),
        backgroundColor: Colors.redAccent,
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
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF2F3F7),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
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
      backgroundColor: isError ? Colors.redAccent : Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    ),
  );
}
