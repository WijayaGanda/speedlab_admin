import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/controllers/klaim_garansi_list_controller.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/views/klaim_garansi_list_view.dart';

class FakeVerifyController extends KlaimGaransiListController {
  FakeVerifyController() : super(provider: WarrantyClaimProvider());

  @override
  void onInit() {}
  @override
  var isLoading = false.obs;

  @override
  List<WarrantyModel> getWarrantiesByStatus(String status) {
    if (status == 'Menunggu Verifikasi') {
      return [
        WarrantyModel.fromJson({
          '_id': 'GW-001', // 🔥 Ganti 'id' menjadi '_id'
          'status': 'Menunggu Verifikasi',
          'motorcycleId': {'model': 'Vario 125'},
          'userId': {'name': 'User Test'},
        }),
      ];
    }
    return [];
  }

  bool isVerifyCalled = false;
  @override
  Future<void> verifyWarranty(String warrantyId) async {
    isVerifyCalled = true;
  }
}

void main() {
  testWidgets('Skenario: Verifikasi Klaim Garansi', (
    WidgetTester tester,
  ) async {
    Get.put<KlaimGaransiListController>(FakeVerifyController());
    await tester.pumpWidget(const GetMaterialApp(home: KlaimGaransiListView()));
    await tester.pumpAndSettle();

    expect(find.text('GW-001'), findsOneWidget);

    final btnVerify = find.text('Verifikasi');
    await tester.tap(btnVerify);

    final controller =
        Get.find<KlaimGaransiListController>() as FakeVerifyController;
    expect(controller.isVerifyCalled, true);
  });
}
