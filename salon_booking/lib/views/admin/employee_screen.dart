import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:salon_booking/views/admin/assign_services_screen.dart';
import 'package:salon_booking/views/admin/new_staff_member_screen.dart';

class EmployeeScreen extends StatelessWidget {
  const EmployeeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1E1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1E1E),
        elevation: 0,
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Team Members",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.filter_list),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF22E6D3),
        onPressed: () => Get.to(() => const NewStaffMemberScreen()),
        child: const Icon(Icons.add, color: Colors.black),
      ),

      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search by name or role...",
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
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

          // Staff List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _staffTile(
                  name: "Sarah Jenkins",
                  role: "Senior Stylist",
                  tags: ["HAIRCUT", "COLORING"],
                  online: true,
                ),
                _staffTile(
                  name: "Mike Ross",
                  role: "Barber",
                  tags: ["SHAVE", "FADE"],
                  online: false,
                ),
                _staffTile(
                  name: "Jessica Pearson",
                  role: "Manager",
                  tags: ["ADMIN", "FINANCE"],
                  online: true,
                ),
                _staffTile(
                  name: "David Chen",
                  role: "Junior Stylist",
                  tags: ["WASH", "BLOW DRY"],
                  online: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _staffTile({
    required String name,
    required String role,
    required List<String> tags,
    required bool online,
  }) {
    return GestureDetector(
      onTap: () => Get.to(() => const AssignServicesScreen()),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF162B2B),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                const CircleAvatar(radius: 26),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: online ? Colors.greenAccent : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(role, style: const TextStyle(color: Colors.white54)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map(
                          (t) => Chip(
                            label: Text(
                              t,
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: const Color(
                              0xFF22E6D3,
                            ).withOpacity(.15),
                            labelStyle: const TextStyle(
                              color: Color(0xFF22E6D3),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
