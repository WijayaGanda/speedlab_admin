import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';

import '../controllers/service_history_controller.dart';

class ServiceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ServiceHistoryController>(
      () => ServiceHistoryController(
        provider: Get.find<ServiceHistoryProvider>(),
      ),
    );
  }
}
