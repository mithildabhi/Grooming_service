// lib/views/admin/gallery_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_controller.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AdminController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon Gallery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: () => _pickAndUpload(context, ctrl),
          ),
        ],
      ),
      body: Obx(() {
        final list = ctrl.galleryList;
        if (list.isEmpty) return const Center(child: Text('No photos yet'));
        return GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final g = list[i];
            return Stack(
              children: [
                Positioned.fill(
                  child: Image.network(g['url'] ?? '', fit: BoxFit.cover),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () async {
                      final ok = await Get.dialog<bool>(
                        AlertDialog(
                          title: const Text('Delete photo?'),
                          actions: [
                            TextButton(
                              onPressed: () => Get.back(result: false),
                              child: const Text('No'),
                            ),
                            TextButton(
                              onPressed: () => Get.back(result: true),
                              child: const Text('Yes'),
                            ),
                          ],
                        ),
                      );
                      if (ok == true) ctrl.deleteGalleryImage(g['id']);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      }),
    );
  }

  void _pickAndUpload(BuildContext context, AdminController ctrl) async {
    final fromCamera = await showModalBottomSheet<bool>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Camera'),
            onTap: () => Navigator.pop(context, true),
          ),
          ListTile(
            title: const Text('Gallery'),
            onTap: () => Navigator.pop(context, false),
          ),
        ],
      ),
    );
    if (fromCamera == null) return;
    ctrl.pickAndUploadGalleryImage(fromCamera: fromCamera);
  }
}
