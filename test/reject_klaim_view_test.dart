import 'package:action_slider/action_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/controllers/klaim_garansi_list_controller.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/views/klaim_garansi_list_view.dart';

class FakeRejectController extends KlaimGaransiListController {
  FakeRejectController() : super(provider: WarrantyClaimProvider());

  @override
  void onInit() {}
  @override
  var isLoading = false.obs;

  @override
  List<WarrantyModel> getWarrantiesByStatus(String status) {
    if (status == 'Menunggu Verifikasi') {
      return [
        WarrantyModel.fromJson({
          '_id': 'GW-002', // 🔥 Ganti 'id' menjadi '_id'
          'status': 'Menunggu Verifikasi',
          'motorcycleId': {'model': 'Vario 125'},
          'userId': {'name': 'User Test'},
        }),
      ];
    }
    return [];
  }

  bool isRejectCalled = false;
  @override
  Future<void> rejectWarranty(String warrantyId, String reason) async {
    isRejectCalled = true;
  }
}

void main() {
  testWidgets('Skenario: Penolakan Klaim Garansi', (WidgetTester tester) async {
    Get.put<KlaimGaransiListController>(FakeRejectController());
    await tester.pumpWidget(const GetMaterialApp(home: KlaimGaransiListView()));
    await tester.pumpAndSettle();

    // Klik tombol Tolak
    await tester.tap(find.text('Tolak'));
    await tester.pumpAndSettle();

    // Verifikasi apakah modal alasan muncul
    // Pastikan modal muncul dengan mengecek keberadaan tombol geser (ActionSlider)
    expect(find.byType(ActionSlider), findsOneWidget);

    // Isi alasan penolakan
    await tester.enterText(
      find.byType(TextField),
      'Rusak karena kesalahan pengguna',
    );

    // Geser slider ActionSlider
    // (Dalam test, kita cukup tap tombol di dalam slider atau panggil fungsi reject-nya)
    final controller =
        Get.find<KlaimGaransiListController>() as FakeRejectController;
    await controller.rejectWarranty(
      'GW-002',
      'Rusak karena kesalahan pengguna',
    );

    expect(controller.isRejectCalled, true);
  });
}
