import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'package:salon_booking/theme/app_colors.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final name = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextDark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create Account",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            const Text(
              "Join us for a better salon experience",
              style: TextStyle(color: kHint),
            ),

            const SizedBox(height: 24),
            _input(name, "Full Name", Icons.person),
            const SizedBox(height: 16),
            _input(email, "Email", Icons.email),
            const SizedBox(height: 16),
            _input(phone, "Phone Number", Icons.phone),
            const SizedBox(height: 16),
            _input(password, "Password", Icons.lock, obscure: true),

            const SizedBox(height: 28),
            _primaryButton(
              text: "Register →",
              onTap: () {
                if (email.text.isEmpty || password.text.isEmpty) {
                  Get.snackbar("Error", "All fields required");
                  return;
                }
                auth.register(
                  email.text.trim(),
                  password.text.trim(),
                  'user',
                );
              },
            ),

            const SizedBox(height: 20),
            Center(
              child: TextButton(
                onPressed: () => Get.back(),
                child: const Text("Already have an account? Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c,
    String hint,
    IconData icon, {
    bool obscure = false,
  }) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: kAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
