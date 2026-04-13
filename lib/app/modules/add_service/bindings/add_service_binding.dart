import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';

import '../controllers/add_service_controller.dart';

class AddServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddServiceController>(
      () => AddServiceController(provider: Get.find<ServiceProvider>()),
    );
  }
}
