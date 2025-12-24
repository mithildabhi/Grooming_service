import 'package:flutter/material.dart';

class AssignServicesScreen extends StatelessWidget {
  const AssignServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text("Assign Services"),
      ),
      body: Column(
        children: [
          ListTile(
            leading: const CircleAvatar(),
            title: const Text(
              "Sarah Jenkins",
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              "Senior Stylist",
              style: TextStyle(color: Colors.white54),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search services...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                _service("Women's Haircut", "45 mins • \$65"),
                _service("Blow Dry & Style", "30 mins • \$45"),
                _service("Full Balayage", "120 mins • \$150"),
                _service("Keratin Smooth", "90 mins • \$120"),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF22E6D3),
                ),
                onPressed: () {},
                child: const Text(
                  "Save Assignments",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _service(String title, String subtitle) {
    return SwitchListTile(
      value: false,
      onChanged: (_) {},
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
      activeColor: const Color(0xFF22E6D3),
    );
  }
}
