import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';

class EditServiceController extends GetxController {
  final ServiceProvider provider;

  var isLoading = false.obs;
  var service = Rxn<ServiceModel>();
  var isWaitable = true.obs;

  late TextEditingController nameCtrl;
  late TextEditingController deskripsiCtrl;
  late TextEditingController hargaCtrl;
  late TextEditingController estimatedDurationCtrl;

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
        text: service.value?.basePrice.toString() ?? '',
      );
      estimatedDurationCtrl = TextEditingController(
        text: service.value?.estimatedDuration.toString() ?? '',
      );
      isWaitable.value = service.value?.isWaitable ?? true;
      // Initialize variants and addons from service if available
      if (service.value?.variants != null &&
          service.value!.variants.isNotEmpty) {
        variants.addAll(
          service.value!.variants
              .map(
                (v) => {
                  'variantName': v.name,
                  'priceModifier': v.priceModifier,
                  'variantDescription': v.description,
                },
              )
              .toList(),
        );
      }
      if (service.value?.availableAddons != null &&
          service.value!.availableAddons.isNotEmpty) {
        addons.addAll(
          service.value!.availableAddons
              .map(
                (a) => {
                  'addonName': a.name,
                  'price': a.price,
                  'type': a.type,
                  'addonDescription': a.description,
                },
              )
              .toList(),
        );
      }
    }
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

  Future<void> updateService() async {
    if (nameCtrl.text.isEmpty ||
        deskripsiCtrl.text.isEmpty ||
        hargaCtrl.text.isEmpty ||
        estimatedDurationCtrl.text.isEmpty) {
      CustomSnackbar.error('Error', 'Semua field harus diisi');
      return;
    }
    try {
      isLoading.value = true;

      // Transform variants from UI format to API format
      final transformedVariants =
          variants
              .map(
                (v) => {
                  'name': v['variantName'] ?? '',
                  'priceModifier': v['priceModifier'] ?? 0.0,
                  'description': v['variantDescription'] ?? '',
                },
              )
              .toList();

      // Transform addons from UI format to API format
      final transformedAddons =
          addons
              .map(
                (a) => {
                  'name': a['addonName'] ?? '',
                  'price': a['price'] ?? 0.0,
                  'type': a['type'] ?? 'OPTIONAL',
                  'description': a['addonDescription'] ?? '',
                },
              )
              .toList();

      final payload = {
        'name': nameCtrl.text,
        'description': deskripsiCtrl.text,
        'basePrice': double.tryParse(hargaCtrl.text) ?? 0.0,
        'estimatedDuration': int.tryParse(estimatedDurationCtrl.text) ?? 0,
        'isWaitable': isWaitable.value,
        'variants': transformedVariants,
        'availableAddons': transformedAddons,
      };

      final response = await provider.updateServices(
        service.value!.id.toString(),
        payload,
      );
      if (response.isOk) {
        CustomSnackbar.success('Success', 'Layanan berhasil diperbarui');
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error('Error', 'Gagal memperbarui layanan');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal memperbarui layanan');
    } finally {
      isLoading.value = false;
    }
  }
}
