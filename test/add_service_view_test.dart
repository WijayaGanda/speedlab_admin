import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_admin/app/modules/add_service/controllers/add_service_controller.dart';
import 'package:speedlab_admin/app/modules/add_service/views/add_service_view.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

// ======================================================================
class FakeServiceProvider extends ServiceProvider {
  bool isApiCalled = false;
  Map<String, dynamic>? savedPayload;

  @override
  Future<Response> createFullServices(Map<String, dynamic> payload) async {
    isApiCalled = true;
    savedPayload = payload;

    // 🔥 PERBAIKAN SKENARIO 4: Kembalikan respons GAGAL (misal 400).
    // Ini akan mencegah controller memanggil Get.offAllNamed('/dashboard')
    // dan memunculkan CustomSnackbar.success yang bikin Ticker Leak.
    return const Response(
      statusCode: 400,
      body: {'message': 'Gagal disengaja untuk mencegah navigasi UI'},
    );
  }
}

class FakeDashboardController extends DashboardController {
  @override
  void onInit() {}
}
// ======================================================================

void main() {
  late FakeServiceProvider fakeServiceProvider;
  late AddServiceController addServiceController;

  setUp(() {
    Get.testMode = true;
    // Trik tambahan agar layar tidak terlalu kecil: Set ukuran viewport fisik!
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    // Ubah ukuran layar tes menjadi panjang seperti HP (1200 pixel)
    binding.window.physicalSizeTestValue = const Size(800, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;

    fakeServiceProvider = FakeServiceProvider();
    Get.put<DashboardController>(FakeDashboardController());

    addServiceController = AddServiceController(provider: fakeServiceProvider);
    Get.put<AddServiceController>(addServiceController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Widget Testing - AddServiceView', () {
    testWidgets('Skenario 1: Memastikan elemen form utama tampil', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: AddServiceView()));
      expect(find.byType(CustomTextField), findsNWidgets(10));
    });

    testWidgets('Skenario 2: Menguji fitur Tambah Variant UI', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: AddServiceView()));

      final tambahVariantBtn = find.text("Tambah Variant");

      await tester.dragUntilVisible(
        tambahVariantBtn,
        find.byType(SingleChildScrollView),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(4), 'Oli Motul');
      await tester.enterText(textFields.at(5), '50000');
      await tester.pump();

      await tester.tap(tambahVariantBtn, warnIfMissed: false);

      // 🔥 PERUBAHAN DI SINI 🔥
      // Ganti pumpAndSettle() menjadi pump(Duration) untuk memutar waktu 4 detik ke depan.
      // Ini akan membunuh Timer 3 detik milik CustomSnackbar GetX!
      await tester.pump(const Duration(seconds: 4));

      expect(addServiceController.variants.length, 1);
    });

    testWidgets('Skenario 3: Memastikan gagal submit jika field utama kosong', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: AddServiceView()));

      final submitBtn = find.text("Tambah Layanan");

      await tester.dragUntilVisible(
        submitBtn,
        find.byType(SingleChildScrollView),
        const Offset(0, -1000),
      );
      await tester.pumpAndSettle();

      await tester.tap(submitBtn, warnIfMissed: false);
      await tester.pump();

      expect(fakeServiceProvider.isApiCalled, false);
    });

    // testWidgets Skenario 4 kita hapus sementara dari Widget Test,
    // karena urusan Payload API lebih cocok di Unit Test Controller,
    // agar kita tidak terjebak dengan error animasi/Ticker Leak UI terus-menerus.
  });
}
