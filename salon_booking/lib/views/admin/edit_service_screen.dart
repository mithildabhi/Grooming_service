import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/ui/glass_card.dart';
import '../../theme/app_spacing.dart';

class EditServiceScreen extends StatefulWidget {
  const EditServiceScreen({super.key});

  @override
  State<EditServiceScreen> createState() => _EditServiceScreenState();
}

class _EditServiceScreenState extends State<EditServiceScreen> {
  static const Color bg = Color(0xFF0B0F14);
  static const Color card = Color(0xFF121A22);
  static const Color accent = Color(0xFF19F6E8);

  late TextEditingController nameCtrl;
  late TextEditingController priceCtrl;
  late TextEditingController durationCtrl;
  late TextEditingController descCtrl;
  late RxString category;
  late RxBool isActive;
  late RxBool isVisible;

  ServiceModel? service;
  bool isInitialized = false;

  final List<Map<String, String>> categories = [
    {'value': 'hair', 'label': 'Hair'},
    {'value': 'spa', 'label': 'Spa'},
    {'value': 'nails', 'label': 'Nails'},
    {'value': 'facial', 'label': 'Facial'},
    {'value': 'massage', 'label': 'Massage'},
    {'value': 'waxing', 'label': 'Waxing'},
    {'value': 'makeup', 'label': 'Makeup'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  void initState() {
    super.initState();

    // Get service from arguments
    service = Get.arguments as ServiceModel?;

    if (service != null) {
      nameCtrl = TextEditingController(text: service!.name);
      priceCtrl = TextEditingController(text: service!.price.toString());
      durationCtrl = TextEditingController(text: service!.duration.toString());
      descCtrl = TextEditingController(text: service!.description);
      category = service!.category.obs;
      isActive = service!.isActive.obs;
      isVisible = service!.isActive.obs; // Using isActive as visibility flag
      isInitialized = true;
    } else {
      // Fallback if no service passed
      nameCtrl = TextEditingController();
      priceCtrl = TextEditingController();
      durationCtrl = TextEditingController();
      descCtrl = TextEditingController();
      category = 'hair'.obs;
      isActive = true.obs;
      isVisible = true.obs;
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    durationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Category',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...categories.map(
                (cat) => Obx(
                  () => ListTile(
                    title: Text(
                      cat['label']!,
                      style: const TextStyle(color: Colors.white),
                    ),
                    trailing: category.value == cat['value']
                        ? const Icon(Icons.check, color: accent)
                        : const SizedBox.shrink(),
                    onTap: () {
                      category.value = cat['value']!;
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateService() async {
    if (service == null) return;

    // Validation
    if (nameCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter service name',
        isError: true,
      );
      return;
    }

    if (priceCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter price',
        isError: true,
      );
      return;
    }

    if (durationCtrl.text.trim().isEmpty) {
      CustomSnackbar.show(
        title: 'Error',
        message: 'Please enter duration',
        isError: true,
      );
      return;
    }

    final ctrl = Get.find<AdminController>();

    try {
      await ctrl.updateService(
        serviceId: service!.id,
        name: nameCtrl.text.trim(),
        description: descCtrl.text.trim(),
        price: double.tryParse(priceCtrl.text) ?? 0,
        duration: int.tryParse(durationCtrl.text) ?? 0,
        category: category.value,
        isActive: isActive.value,
      );
    } catch (e) {
      // Error is already handled in controller
    }
  }

  Future<void> _deleteService() async {
    if (service == null) return;

    // Show confirmation dialog
    final confirm = await Get.dialog<bool>(
      Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: GlassCard(
            color: card,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber,
                    color: Colors.redAccent,
                    size: 48,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Delete Service',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Are you sure you want to delete this service? This action cannot be undone.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white24),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Delete"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (confirm == true) {
      final ctrl = Get.find<AdminController>();
      try {
        await ctrl.deleteService(serviceId: service!.id);
      } catch (e) {
        // Error is already handled in controller
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialized || service == null) {
      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          title: const Text(
            'Edit Service',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: Text(
            'No service data found',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    final ctrl = Get.find<AdminController>();

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Text(
          'Edit Service',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (ctrl.isLoadingServices.value) {
          return const Center(child: CircularProgressIndicator(color: accent));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _aiSuggestion(),
              const SizedBox(height: 24),

              _sectionTitle('Service Details'),
              const SizedBox(height: 12),

              _inputField('Service Name', nameCtrl, Icons.cut),
              _inputField(
                'Price (₹)',
                priceCtrl,
                Icons.currency_rupee,
                keyboardType: TextInputType.number,
              ),
              _inputField(
                'Duration (minutes)',
                durationCtrl,
                Icons.access_time,
                keyboardType: TextInputType.number,
              ),

              _dropdownTile(),

              _multilineField('Description', descCtrl),

              const SizedBox(height: 24),

              _sectionTitle('Service Status'),
              const SizedBox(height: 12),

              _statusTile('Active', isActive),
              _statusTile('Visible to customers', isVisible),

              const SizedBox(height: 32),

              _actionButtons(),
              const SizedBox(height: 40),
            ],
          ),
        );
      }),
    );
  }

  Widget _aiSuggestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.psychology, color: accent, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              service != null && service!.duration < 30
                  ? 'Great! Services under 30 mins get 40% more bookings.'
                  : 'AI suggests increasing the price by 10% due to high demand during weekends.',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          prefixIcon: Icon(icon, color: accent),
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _multilineField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: 4,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          alignLabelWithHint: true,
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _dropdownTile() => Obx(
    () => GestureDetector(
      onTap: _showCategoryPicker,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.category, color: accent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Category: ${categories.firstWhere((c) => c['value'] == category.value)['label']}",
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    ),
  );

  Widget _statusTile(String title, RxBool enabled) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            Switch(
              value: enabled.value,
              activeColor: accent,
              onChanged: (val) async {
                // Update the switch immediately for better UX
                enabled.value = val;

                // If it's the Active toggle, update backend immediately
                if (title == 'Active' && service != null) {
                  try {
                    final ctrl = Get.find<AdminController>();
                    await ctrl.toggleServiceStatus(
                      serviceId: service!.id,
                      isActive: val,
                    );

                    CustomSnackbar.show(
                      title: 'Success',
                      message: 'Service status updated',
                      isSuccess: true,
                      duration: const Duration(seconds: 2),
                    );
                  } catch (e) {
                    // Revert on error
                    enabled.value = !val;
                    CustomSnackbar.show(
                      title: 'Error',
                      message: 'Failed to update status',
                      isError: true,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _updateService,
            child: const Text(
              'Save Changes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: _deleteService,
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}
