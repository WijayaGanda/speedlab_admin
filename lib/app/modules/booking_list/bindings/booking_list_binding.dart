import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';

import '../controllers/booking_list_controller.dart';

class BookingListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingListController>(
      () => BookingListController(
        provider: Get.find<BookingsProvider>(),
        serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
        authService: Get.find<AuthService>(),
      ),
    );
  }
}
