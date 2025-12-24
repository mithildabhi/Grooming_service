import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final password = TextEditingController();
    final role = TextEditingController(text: 'user');
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(title: const Text("Create Account")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _input(email, "Email", Icons.email),
            const SizedBox(height: 16),
            _input(password, "Password", Icons.lock, obscure: true),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: role.text,
              decoration: const InputDecoration(
                labelText: "Account Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'user', child: Text("Customer")),
                DropdownMenuItem(value: 'admin', child: Text("Salon Admin")),
              ],
              onChanged: (v) => role.text = v ?? 'user',
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (email.text.isEmpty || password.text.isEmpty) {
                    Get.snackbar("Error", "All fields required");
                    return;
                  }
                  auth.register(
                    email.text.trim(),
                    password.text.trim(),
                    role.text,
                  );
                },
                child: const Text("Create Account"),
              ),
            ),
          ],
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
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
