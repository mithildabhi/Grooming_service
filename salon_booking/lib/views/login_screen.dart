import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'register_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const bg = Color(0xFF0B0F14);
  static const accent = Color(0xFF19F6E8);

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _card(
            child: Column(
              children: [
                const Icon(Icons.lock, size: 60, color: accent),
                const SizedBox(height: 16),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                _input(email, "Email", Icons.email),
                const SizedBox(height: 16),
                _input(password, "Password", Icons.lock, obscure: true),

                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: accent),
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                _button(
                  text: "Login",
                  onTap: () {
                    if (email.text.isEmpty || password.text.isEmpty) {
                      Get.snackbar("Error", "All fields required");
                      return;
                    }
                    auth.login(email.text.trim(), password.text.trim());
                  },
                ),

                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Get.to(() => const RegisterScreen()),
                  child: const Text(
                    "Create new account",
                    style: TextStyle(color: accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );

  Widget _input(
    TextEditingController c,
    String h,
    IconData i, {
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(i),
        hintText: h,
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _button({required String text, required VoidCallback onTap}) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.black,
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
