import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class EditServiceController extends GetxController {
  final ServiceProvider provider;

  var isLoading = false.obs;
  var service = Rxn<ServiceModel>();
  late TextEditingController nameCtrl;
  late TextEditingController deskripsiCtrl;
  late TextEditingController hargaCtrl;
  late TextEditingController estimatedDurationCtrl;
  EditServiceController({required this.provider});

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null) {
      service.value = Get.arguments as ServiceModel;
      debugPrint('Service ID: ${service.value!.id}');
      nameCtrl = TextEditingController(text: service.value?.name ?? '');
      deskripsiCtrl = TextEditingController(
        text: service.value?.description ?? '',
      );
      hargaCtrl = TextEditingController(
        text: service.value?.price.toString() ?? '',
      );
      estimatedDurationCtrl = TextEditingController(
        text: service.value?.estimatedDuration.toString() ?? '',
      );
    }
  }

  Future<void> updateService() async {
    if (nameCtrl.text.isEmpty ||
        deskripsiCtrl.text.isEmpty ||
        hargaCtrl.text.isEmpty ||
        estimatedDurationCtrl.text.isEmpty) {
      Get.snackbar('Error', 'Semua field harus diisi');
      return;
    }
    try {
      isLoading.value = true;
      final response = await provider
          .updateServices(service.value!.id.toString(), {
            'name': nameCtrl.text,
            'description': deskripsiCtrl.text,
            'price': double.tryParse(hargaCtrl.text) ?? 0.0,
            'estimatedDuration': estimatedDurationCtrl.text,
          });
      if (response.isOk) {
        CustomSnackbar.success('Success', 'Layanan berhasil diperbarui');
        Get.offAllNamed('/dashboard');
      } else {
        Get.snackbar('Error', 'Gagal memperbarui layanan');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memperbarui layanan');
    } finally {
      isLoading.value = false;
    }
  }
}
