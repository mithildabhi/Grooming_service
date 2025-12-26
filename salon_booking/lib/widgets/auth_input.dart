import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;

  const AuthInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Color(0xFF111827)),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: const Color(0xFF19F6E8)),
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF6B7280)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
