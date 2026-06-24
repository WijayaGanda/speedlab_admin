import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/modules/dete_override/bindings/dete_override_binding.dart';
import 'package:speedlab_admin/app/modules/dete_override/controllers/dete_override_controller.dart';

import '../controllers/operating_hour_controller.dart';

class OperatingHourBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OperatingHourController>(
      () => OperatingHourController(provider: Get.find<BookingsProvider>()),
    );
    Get.lazyPut<DeteOverrideController>(
      () => DeteOverrideController(provider: Get.find<BookingsProvider>()),
    );
  }
}
