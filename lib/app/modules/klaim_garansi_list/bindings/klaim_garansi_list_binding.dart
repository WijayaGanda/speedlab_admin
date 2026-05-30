import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';

import '../controllers/klaim_garansi_list_controller.dart';

class KlaimGaransiListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KlaimGaransiListController>(
      () => KlaimGaransiListController(
        provider: Get.find<WarrantyClaimProvider>(),
      ),
    );
  }
}
