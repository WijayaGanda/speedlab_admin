import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:flutter/material.dart';

class AddServiceController extends GetxController {
  final ServiceProvider provider;

  AddServiceController({required this.provider});

  var isLoading = false.obs;
  var nameCtrl = TextEditingController();
  var deskripsiCtrl = TextEditingController();
  var hargaCtrl = TextEditingController();
  var estimatedDurationCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> addService() async {
    try {
      isLoading.value = true;
      final response = await provider.createServices({
        'name': nameCtrl.text,
        'description': deskripsiCtrl.text,
        'price': double.tryParse(hargaCtrl.text) ?? 0.0,
        'estimatedDuration': estimatedDurationCtrl.text,
      });
      if (response.isOk) {
        Get.snackbar('Success', 'Layanan berhasil ditambahkan');
        Get.back();
      } else {
        Get.snackbar('Error', 'Gagal menambahkan layanan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menambahkan layanan');
    } finally {
      isLoading.value = false;
    }
  }
}
