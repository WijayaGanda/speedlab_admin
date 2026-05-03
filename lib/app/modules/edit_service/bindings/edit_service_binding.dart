import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';

import '../controllers/edit_service_controller.dart';

class EditServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditServiceController>(
      () => EditServiceController(provider: Get.find<ServiceProvider>()),
    );
  }
}
