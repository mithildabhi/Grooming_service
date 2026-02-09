import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/custom_snackbar.dart';
import '../controllers/auth_controller.dart';
import 'package:salon_booking/theme/app_colors.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = TextEditingController();
    final auth = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: kTextDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              CircleAvatar(
                radius: 36,
                backgroundColor: kAccent.withOpacity(0.15),
                child: const Icon(Icons.lock_reset, size: 36, color: kAccent),
              ),
              const SizedBox(height: 24),
              const Text(
                "Forgot Password",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                "We’ll help you reset it.",
                style: TextStyle(color: kHint),
              ),

              const SizedBox(height: 32),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  hintText: "Enter your email address",
                  prefixIcon: const Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (!GetUtils.isEmail(email.text)) {
                      CustomSnackbar.show(title: "Error", message: "Enter valid email", isError: true);
                      return;
                    }
                    auth.resetPassword(email.text.trim());
                  },
                  child: const Text(
                    "Send Reset Link",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Get.back(),
                child: const Text("Back to Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
