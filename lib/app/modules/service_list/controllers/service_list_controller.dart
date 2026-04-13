import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';

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
        Get.snackbar('Error', 'Gagal memuat layanan servis');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat layanan servis');
    } finally {
      isLoading.value = false;
    }
  }

  void moveToAddService() {
    Get.toNamed('/add-service', arguments: services);
  }
}
