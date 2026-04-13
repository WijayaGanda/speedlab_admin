import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';

import '../controllers/service_list_controller.dart';

class ServiceListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceListController>(
      () => ServiceListController(serviceProvider: Get.find<ServiceProvider>()),
    );
  }
}
