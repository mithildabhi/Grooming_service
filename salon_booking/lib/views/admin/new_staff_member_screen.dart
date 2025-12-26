import 'package:flutter/material.dart';

class NewStaffMemberScreen extends StatelessWidget {
  const NewStaffMemberScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("New Staff Member"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 48,
              backgroundColor: Colors.white24,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Upload Photo",
              style: TextStyle(color: Color(0xFF22E6D3)),
            ),

            const SizedBox(height: 30),
            _field("Full Name", "e.g. Sarah Jones"),
            _field("Role", "Select a role", dropdown: true),
            _field("Email Address", "name@salon.com"),
            _field("Phone Number", "(555) 000-0000"),
            _field(
              "Bio (Optional)",
              "Short description about the staff member...",
              maxLines: 3,
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22E6D3),
                ),
                onPressed: () {},
                child: const Text(
                  "Create Profile",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    String label,
    String hint, {
    bool dropdown = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixIcon: dropdown ? const Icon(Icons.keyboard_arrow_down) : null,
          filled: true,
          fillColor: Colors.white10,
          labelStyle: const TextStyle(color: Colors.white70),
          hintStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
