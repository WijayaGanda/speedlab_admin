import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';

import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(provider: Get.find<BookingsProvider>()),
    );
  }
}
