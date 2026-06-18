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
  var isWaitable = true.obs;

  var isLoading = false.obs;
  var nameCtrl = TextEditingController();
  var deskripsiCtrl = TextEditingController();
  var hargaCtrl = TextEditingController();
  var estimatedDurationCtrl = TextEditingController();

  // Variants
  var variants = RxList<Map<String, dynamic>>([]);
  var variantNameCtrl = TextEditingController();
  var variantPriceModifierCtrl = TextEditingController();
  var variantDescCtrl = TextEditingController();

  // Addons
  var addons = RxList<Map<String, dynamic>>([]);
  var addonNameCtrl = TextEditingController();
  var addonPriceCtrl = TextEditingController();
  var addonDescCtrl = TextEditingController();
  var selectedAddonType = 'OPTIONAL'.obs;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    deskripsiCtrl.dispose();
    hargaCtrl.dispose();
    estimatedDurationCtrl.dispose();
    variantNameCtrl.dispose();
    variantPriceModifierCtrl.dispose();
    variantDescCtrl.dispose();
    addonNameCtrl.dispose();
    addonPriceCtrl.dispose();
    addonDescCtrl.dispose();
    super.onClose();
  }

  void addVariant() {
    if (variantNameCtrl.text.isEmpty) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'Nama variant harus diisi',
      );
      return;
    }

    variants.add({
      'variantName': variantNameCtrl.text,
      'priceModifier': double.tryParse(variantPriceModifierCtrl.text) ?? 0.0,
      'variantDescription': variantDescCtrl.text,
    });

    variantNameCtrl.clear();
    variantPriceModifierCtrl.clear();
    variantDescCtrl.clear();

    CustomSnackbar.success('Success', 'Variant berhasil ditambahkan');
  }

  void removeVariant(int index) {
    variants.removeAt(index);
    CustomSnackbar.success('Success', 'Variant berhasil dihapus');
  }

  void addAddon() {
    if (addonNameCtrl.text.isEmpty) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'Nama addon harus diisi',
      );
      return;
    }

    addons.add({
      'addonName': addonNameCtrl.text,
      'price': double.tryParse(addonPriceCtrl.text) ?? 0.0,
      'type': selectedAddonType.value,
      'addonDescription': addonDescCtrl.text,
    });

    addonNameCtrl.clear();
    addonPriceCtrl.clear();
    addonDescCtrl.clear();
    selectedAddonType.value = 'OPTIONAL';

    CustomSnackbar.success('Success', 'Addon berhasil ditambahkan');
  }

  void removeAddon(int index) {
    addons.removeAt(index);
    CustomSnackbar.success('Success', 'Addon berhasil dihapus');
  }

  Future<void> addService() async {
    if (nameCtrl.text.isEmpty ||
        deskripsiCtrl.text.isEmpty ||
        estimatedDurationCtrl.text.isEmpty) {
      CustomModal.showErrorDialog(
        title: 'Error',
        message: 'Semua field utama harus diisi',
      );
      return;
    }

    try {
      isLoading.value = true;

      final payload = {
        'name': nameCtrl.text,
        'category': 'REMAP',
        'basePrice': double.tryParse(hargaCtrl.text) ?? 0.0,
        'description': deskripsiCtrl.text,
        'estimatedDuration': int.tryParse(estimatedDurationCtrl.text) ?? 0,
        'isWaitable': isWaitable.value,
        'isActive': true,
        'variants': variants.toList(),
        'availableAddons': addons.toList(),
      };

      final response = await provider.createFullServices(payload);

      if (response.isOk) {
        CustomSnackbar.success('Success', 'Layanan berhasil ditambahkan');
        // Clear all data
        nameCtrl.clear();
        deskripsiCtrl.clear();
        hargaCtrl.clear();
        estimatedDurationCtrl.clear();
        variants.clear();
        addons.clear();
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error(
          'Error',
          'Gagal menambahkan layanan: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint('❌ Exception occurred: $e');
      debugPrint('StackTrace: ${StackTrace.current}');
      CustomSnackbar.error('Error', 'Gagal menambahkan layanan: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
