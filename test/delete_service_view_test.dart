import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/modules/add_service/controllers/add_service_controller.dart';
import 'package:speedlab_admin/app/modules/add_service/views/add_service_view.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/dashboard/controllers/dashboard_controller.dart';

// FAKE CONTROLLER KHUSUS HAPUS
class FakeDeleteController extends AddServiceController {
  FakeDeleteController() : super(provider: ServiceProvider());

  @override
  void onInit() {
    variants.add({
      'variantName': 'Varian 1',
      'priceModifier': 10000.0,
      'variantDescription': '',
    });
  }

  @override
  void removeVariant(int index) {
    variants.removeAt(index);
  }
}

// 🔥 MODIFIKASI: Gunakan 'extends DashboardController'
// agar Dart tidak komplain soal type mismatch
class FakeDashboardController extends DashboardController {
  @override
  void onInit() {
    // Kosongkan agar tidak memicu logic asli
  }
}

void main() {
  testWidgets(
    'Skenario: Menekan icon hapus akan menghilangkan item dari daftar',
    (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(1080, 2400);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      Get.put<DashboardController>(FakeDashboardController());
      Get.put<AddServiceController>(FakeDeleteController());

      await tester.pumpWidget(const GetMaterialApp(home: AddServiceView()));
      await tester.pumpAndSettle();

      // 1. Verifikasi item ada
      expect(find.text('Varian 1'), findsOneWidget);

      // 2. CARI ICON DELETE YANG SPESIFIK
      // Kita gunakan 'find.byType(IconButton)' agar lebih spesifik
      // atau gunakan 'find.descendant' jika ikon hapus ada di dalam list item
      final deleteButton = find.descendant(
        of: find.byType(Card), // Asumsi item list Anda dibungkus Card
        matching: find.byIcon(Icons.delete),
      );

      // Pastikan tombol hapus ditemukan
      expect(deleteButton, findsOneWidget);

      // 3. TAP DENGAN AMAN
      await tester.tap(deleteButton, warnIfMissed: false);
      await tester.pumpAndSettle();

      // 4. VERIFIKASI ITEM HILANG
      // Kita gunakan findsNothing untuk memastikan "Varian 1" sudah terhapus dari controller
      expect(find.text('Varian 1'), findsNothing);
    },
  );
}
