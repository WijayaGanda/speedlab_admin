import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:flutter/material.dart';
import 'package:speedlab_admin/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class AddServiceController extends GetxController {
  final ServiceProvider provider;

  AddServiceController({required this.provider});

  final dashController = Get.find<DashboardController>();

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
    if (nameCtrl.text.isEmpty ||
        deskripsiCtrl.text.isEmpty ||
        hargaCtrl.text.isEmpty ||
        estimatedDurationCtrl.text.isEmpty) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'Semua field harus diisi',
      );
      return;
    }
    try {
      isLoading.value = true;
      final response = await provider.createServices({
        'name': nameCtrl.text,
        'description': deskripsiCtrl.text,
        'price': double.tryParse(hargaCtrl.text) ?? 0.0,
        'estimatedDuration': estimatedDurationCtrl.text,
      });
      if (response.isOk) {
        CustomSnackbar.success('Success', 'Layanan berhasil ditambahkan');
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error('Error', 'Gagal menambahkan layanan');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal menambahkan layanan');
    } finally {
      isLoading.value = false;
    }
  }
}
