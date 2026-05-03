import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/booking_list/controllers/booking_list_controller.dart';
import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_admin/app/modules/service_list/controllers/service_list_controller.dart';

import '../controllers/dashboard_controller.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<BookingsProvider>(BookingsProvider());
    Get.put<ServiceHistoryProvider>(ServiceHistoryProvider());
    Get.put<ServiceProvider>(ServiceProvider());
    Get.put<NotifProvider>(NotifProvider());

    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(
      () => HomeController(provider: Get.find<BookingsProvider>()),
    );
    Get.lazyPut<ServiceListController>(
      () => ServiceListController(serviceProvider: Get.find<ServiceProvider>()),
    );
    Get.lazyPut<BookingListController>(
      () => BookingListController(
        provider: Get.find<BookingsProvider>(),
        serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
      ),
    );
  }
}
