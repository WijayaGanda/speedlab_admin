import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/motorcycles_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';

import '../controllers/walkin_customer_controller.dart';

class WalkinCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthProvider>(AuthProvider());
    Get.put<MotorcyclesProvider>(MotorcyclesProvider());
    Get.put<BookingsProvider>(BookingsProvider());
    Get.put<ServiceProvider>(ServiceProvider());

    Get.lazyPut<WalkinCustomerController>(
      () => WalkinCustomerController(
        provider: Get.find<BookingsProvider>(),
        serviceProvider: Get.find<ServiceProvider>(),
        authProvider: Get.find<AuthProvider>(),
        motorcyclesProvider: Get.find<MotorcyclesProvider>(),
        bookingsProvider: Get.find<BookingsProvider>(),
      ),
    );
  }
}
