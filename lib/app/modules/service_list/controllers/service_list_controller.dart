import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

class ServiceListController extends GetxController {
  final ServiceProvider serviceProvider;

  ServiceListController({required this.serviceProvider});
  var services = <ServiceModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchServices();
  }

  Future<void> fetchServices() async {
    try {
      isLoading.value = true;
      final response = await serviceProvider.fetchServices();
      if (response.isOk && response.body != null) {
        final servicesResponse = ServiceResponse.fromJson(response.body);
        services.value = servicesResponse.data;
      } else {
        debugPrint('Failed to load services: ${response.statusCode} ${response.statusText}');
      }
    } catch (e) {
      debugPrint('Error occurred while fetching services: $e');
      Get.snackbar('Error', 'Gagal memuat layanan servis');
    } finally {
      isLoading.value = false;
    }
  }

  void moveToAddService() {
    Get.toNamed('/add-service');
  }

  void moveToEditService(ServiceModel service) {
    Get.toNamed('/edit-service', arguments: service);
  }

  Future<void> deleteService(String id) async {
    try {
      isLoading.value = true;
      final response = await serviceProvider.deleteService(id);
      if (response.isOk) {
        CustomSnackbar.success('Success', 'Layanan berhasil dihapus');
        Get.offAllNamed('/dashboard');
      } else {
        CustomSnackbar.error('Error', 'Gagal menghapus layanan');
      }
    } catch (e) {
      CustomSnackbar.error('Error', 'Gagal menghapus layanan');
    } finally {
      isLoading.value = false;
    }
  }
}
