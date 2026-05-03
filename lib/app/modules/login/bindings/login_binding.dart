import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';

import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        provider: Get.find<AuthProvider>(),
        notifProvider: Get.find<NotifProvider>(),
      ),
    );
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<NotifProvider>(() => NotifProvider());
  }
}
