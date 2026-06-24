import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';

import '../controllers/dete_override_controller.dart';

class DeteOverrideBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeteOverrideController>(
      () => DeteOverrideController(provider: Get.find<BookingsProvider>()),
    );
  }
}
