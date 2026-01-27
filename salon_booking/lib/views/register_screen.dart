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

    // ✅ ROLE STATE (DEFAULT = USER)
    final RxString selectedRole = 'user'.obs;
    
    // ✅ GENDER STATE
    final RxString selectedGender = 'NOT_SPECIFIED'.obs;

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

            // ✅ ROLE SELECTION (ADDED)
            const Text(
              "Register as",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),

            Obx(
              () => Row(
                children: [
                  _roleChip(
                    label: "User",
                    role: "user",
                    selectedRole: selectedRole,
                  ),
                  const SizedBox(width: 12),
                  _roleChip(
                    label: "Admin",
                    role: "admin",
                    selectedRole: selectedRole,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _input(name, "Full Name", Icons.person),
            const SizedBox(height: 16),
            _input(email, "Email", Icons.email),
            const SizedBox(height: 16),
            _input(phone, "Phone Number", Icons.phone),
            const SizedBox(height: 16),
            
            // ✅ GENDER SELECTION
            Obx(() => _genderDropdown(selectedGender)),
            const SizedBox(height: 16),
            
            _input(password, "Password", Icons.lock, obscure: true),

            const SizedBox(height: 28),
            _primaryButton(
              text: "Register →",
              onTap: () {
                // ✅ VALIDATE ALL FIELDS
                if (name.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter your name");
                  return;
                }
                if (email.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter your email");
                  return;
                }
                if (phone.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter your phone number");
                  return;
                }
                if (password.text.trim().isEmpty) {
                  Get.snackbar("Error", "Please enter a password");
                  return;
                }
                if (phone.text.trim().length < 10) {
                  Get.snackbar("Error", "Please enter a valid phone number");
                  return;
                }

                // ✅ PASS ALL DATA INCLUDING NAME, PHONE AND GENDER
                auth.register(
                  email.text.trim(),
                  password.text.trim(),
                  selectedRole.value,
                  name: name.text.trim(),
                  phone: phone.text.trim(),
                  gender: selectedGender.value,  // ← Add gender
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

  // 🔹 ROLE CHIP WIDGET (NEW – SMALL & SAFE)
  static Widget _roleChip({
    required String label,
    required String role,
    required RxString selectedRole,
  }) {
    final bool isSelected = selectedRole.value == role;

    return Expanded(
      child: GestureDetector(
        onTap: () => selectedRole.value = role,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: isSelected ? kAccent : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.black : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ✅ GENDER DROPDOWN WIDGET
  static Widget _genderDropdown(RxString selectedGender) {
    final Map<String, String> genderOptions = {
      'NOT_SPECIFIED': 'Not specified',
      'MALE': 'Male',
      'FEMALE': 'Female',
      'OTHER': 'Other',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: selectedGender.value,
          icon: const Icon(Icons.arrow_drop_down),
          items: genderOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Row(
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  const SizedBox(width: 12),
                  Text(entry.value),
                ],
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              selectedGender.value = newValue;
            }
          },
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

  Widget _primaryButton({required String text, required VoidCallback onTap}) {
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