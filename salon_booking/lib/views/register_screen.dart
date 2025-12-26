import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();
    final role = 'user'.obs;
    final auth = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _input(email, "Email"),
            const SizedBox(height: 16),
            _input(password, "Password", obscure: true),
            const SizedBox(height: 16),

            Obx(
              () => DropdownButtonFormField<String>(
                value: role.value,
                items: const [
                  DropdownMenuItem(value: 'user', child: Text("Customer")),
                  DropdownMenuItem(value: 'admin', child: Text("Salon Admin")),
                ],
                onChanged: (v) => role.value = v ?? 'user',
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Account Type",
                ),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (email.text.isEmpty || password.text.isEmpty) {
                    Get.snackbar("Error", "All fields required");
                    return;
                  }
                  auth.register(
                    email.text.trim(),
                    password.text.trim(),
                    role.value,
                  );
                },
                child: const Text("Register"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _input(TextEditingController c, String hint, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
