import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/booking_model.dart';
import '../../controllers/admin_controller.dart';

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  String? salonId;

  // ✅ MOCK DATA (NO FIREBASE)
  List<Map<String, dynamic>> salons = [];
  List<Map<String, dynamic>> services = [];
  List<Map<String, dynamic>> staff = [];

  Map<String, dynamic>? selService;
  Map<String, dynamic>? selStaff;
  DateTime? selDate;
  TimeOfDay? selTime;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadMockData();
  }

  // -------------------------------
  // MOCK LOADERS (REPLACE FIREBASE)
  // -------------------------------
  void _loadMockData() {
    salons = [
      {'id': 'salon1', 'name': 'Demo Salon'},
    ];

    services = [
      {
        'id': 'service1',
        'name': 'Hair Cut',
        'price': 200,
        'durationMinutes': 30,
      },
      {
        'id': 'service2',
        'name': 'Beard Trim',
        'price': 100,
        'durationMinutes': 15,
      },
    ];

    staff = [
      {'id': 'staff1', 'name': 'John'},
      {'id': 'staff2', 'name': 'Alex'},
    ];

    setState(() {});
  }

  // -------------------------------
  // SUBMIT BOOKING
  // -------------------------------
  Future<void> _submit() async {
    if (salonId == null ||
        selService == null ||
        selDate == null ||
        selTime == null ||
        nameCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing', 'Please complete all fields');
      return;
    }

    setState(() => loading = true);

    final dateStr =
        '${selDate!.year.toString().padLeft(4, '0')}-${selDate!.month.toString().padLeft(2, '0')}-${selDate!.day.toString().padLeft(2, '0')}';

    final timeStr =
        '${selTime!.hour.toString().padLeft(2, '0')}:${selTime!.minute.toString().padLeft(2, '0')}';

    final durRaw = selService!['durationMinutes'] ?? 30;
    final duration = durRaw is int ? durRaw : durRaw.toInt();

    final priceRaw = selService!['price'] ?? 0;
    final price = priceRaw is double ? priceRaw : (priceRaw as int).toDouble();

    final booking = BookingModel(
      id: '',
      userId: 'anonymous',
      customerName: nameCtrl.text.trim(),
      userPhone: phoneCtrl.text.trim(),
      serviceId: selService!['id'],
      serviceName: selService!['name'],
      staffId: selStaff?['id'] ?? '',
      staffName: selStaff?['name'] ?? '',
      date: dateStr,
      time: timeStr,
      durationMinutes: duration,
      status: 'REQUESTED',
      price: price,
      createdAt: DateTime.now(),
    );

    final admin = Get.find<AdminController>();
    await admin.addBooking(booking);

    setState(() => loading = false);

    Get.snackbar('Success', 'Booking requested successfully');
    Get.back();
  }

  // -------------------------------
  // UI (UNCHANGED)
  // -------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book')),
      body: salons.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Salon'),
                    items: salons
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s['id'],
                            child: Text(s['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => salonId = v),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Service'),
                    items: services
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s['id'],
                            child: Text('${s['name']} - ₹${s['price']}'),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      selService = services.firstWhere((x) => x['id'] == v);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Preferred Staff (optional)',
                    ),
                    items: staff
                        .map(
                          (s) => DropdownMenuItem<String>(
                            value: s['id'],
                            child: Text(s['name']),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      selStaff = staff.firstWhere((x) => x['id'] == v);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Your name'),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now().add(
                                const Duration(days: 1),
                              ),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(
                                const Duration(days: 365),
                              ),
                            );
                            if (d != null) setState(() => selDate = d);
                          },
                          child: Text(
                            selDate == null
                                ? 'Pick Date'
                                : '${selDate!.day}-${selDate!.month}-${selDate!.year}',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            final t = await showTimePicker(
                              context: context,
                              initialTime: const TimeOfDay(hour: 10, minute: 0),
                            );
                            if (t != null) setState(() => selTime = t);
                          },
                          child: Text(
                            selTime == null
                                ? 'Pick Time'
                                : selTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: loading ? null : _submit,
                      child: loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Request'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
