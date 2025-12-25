import 'package:flutter/material.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Inventory"),
        actions: [
          Chip(
            label: const Text("AI ACTIVE"),
            backgroundColor: const Color(0xFF19F6E8),
            labelStyle: const TextStyle(color: Colors.black),
          ),
          const SizedBox(width: 12),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🧠 Inventory Health
            _card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventory Health",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Excellent (94%)",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "AI predicts stable stock levels for the next 7 days.",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {},
                    child: const Text("View Analysis →"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// 🚨 Urgent Predictions
            _sectionTitle("Urgent Predictions"),
            const SizedBox(height: 12),

            SizedBox(
              height: 170,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _urgentItem(
                    title: "Argan Shampoo",
                    subtitle: "Empty in 2 days",
                    action: "Reorder",
                    color: Colors.redAccent,
                  ),
                  _urgentItem(
                    title: "Keratin Conditioner",
                    subtitle: "Low Stock (5)",
                    action: "Add to Cart",
                    color: Colors.orangeAccent,
                  ),
                  _urgentItem(
                    title: "Styling Wax",
                    subtitle: "High Demand",
                    action: "Stock Up",
                    color: Colors.greenAccent,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 📊 Usage Forecast
            _sectionTitle("Usage Forecast"),
            const SizedBox(height: 12),

            _card(
              child: Container(
                height: 140,
                alignment: Alignment.center,
                child: const Text("📈 Forecast Chart (Mock)"),
              ),
            ),

            const SizedBox(height: 24),

            /// 📦 All Inventory
            _sectionTitle("All Inventory"),
            const SizedBox(height: 12),

            _inventoryItem(
              title: "Purple Shampoo",
              stock: "24 units",
              burnRate: "3/day",
              status: "Stable",
              statusColor: Colors.green,
            ),
            _inventoryItem(
              title: "Black Hair Dye",
              stock: "2 units",
              burnRate: "5/day",
              status: "Critical",
              statusColor: Colors.red,
            ),
            _inventoryItem(
              title: "Tea Tree Oil",
              stock: "45 units",
              burnRate: "0.5/day",
              status: "Low Velocity",
              statusColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- UI Helpers ----------------

  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF121A22),
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _urgentItem({
    required String title,
    required String subtitle,
    required String action,
    required Color color,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF121A22),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: color)),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: color),
            onPressed: () {},
            child: Text(action),
          ),
        ],
      ),
    );
  }

  Widget _inventoryItem({
    required String title,
    required String stock,
    required String burnRate,
    required String status,
    required Color statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: _card(
        child: Row(
          children: [
            const Icon(Icons.inventory),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "$stock • Burn rate: $burnRate",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Chip(label: Text(status), backgroundColor: statusColor),
          ],
        ),
      ),
    );
  }
}
