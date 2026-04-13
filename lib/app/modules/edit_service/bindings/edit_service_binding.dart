import 'package:get/get.dart';

import '../controllers/edit_service_controller.dart';

class EditServiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditServiceController>(
      () => EditServiceController(),
    );
  }
}
