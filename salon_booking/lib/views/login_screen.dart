import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  get routeName => null;

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final auth = Get.find<AuthController>();

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFDFBFB), Color(0xFFECECEC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Icon(Icons.spa, size: 80, color: Color(0xFF00C9FF)),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "Login to continue",
                  style: TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 30),
                _input(emailController, "Email", Icons.email),
                const SizedBox(height: 16),
                _input(
                  passwordController,
                  "Password",
                  Icons.lock,
                  obscure: true,
                ),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Get.to(() => const ForgotPasswordScreen()),
                    child: const Text("Forgot Password?"),
                  ),
                ),

                const SizedBox(height: 16),
                _primaryButton("Login", () {
                  if (emailController.text.isEmpty ||
                      passwordController.text.isEmpty) {
                    Get.snackbar("Error", "Enter email & password");
                    return;
                  }
                  auth.login(
                    emailController.text.trim(),
                    passwordController.text.trim(),
                  );
                }),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () => Get.to(() => const RegisterScreen()),
                      child: const Text("Register"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController controller,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _primaryButton(String text, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C9FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
