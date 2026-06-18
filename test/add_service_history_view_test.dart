import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Sesuaikan import ini dengan struktur proyek Anda
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/service_history/controllers/service_history_controller.dart';
import 'package:speedlab_admin/app/modules/service_history/views/service_history_view.dart';

// ======================================================================
// 🔥 FAKE CONTROLLER (DENGAN PANCINGAN OBX YANG SEMPURNA)
// ======================================================================

class UltraFakeServiceHistoryController extends ServiceHistoryController {
  UltraFakeServiceHistoryController()
    : super(provider: ServiceHistoryProvider());

  @override
  void onInit() {}

  @override
  var isLoading = false.obs;
  @override
  var isUploading = false.obs;
  @override
  var selectedImagePath = "".obs;
  @override
  var descriptionText = "".obs;

  // Wajib .obs agar Obx di view tidak error
  @override
  var spareParts = <Map<String, String>>[].obs;
  @override
  var serviceHistory = <ServiceHistoryModel>[].obs;

  @override
  var selectedBooking = Rxn<BookingsModel>(
    BookingsModel.fromJson({
      'id': 'BK-999',
      'userId': {'name': 'Budi Santoso'},
    }),
  );

  // 🔥 PANCINGAN OBX UNTUK GETTER 🔥
  var trigger = 0.obs;

  @override
  bool get isFormDisabled {
    trigger.value; // Memancing Obx
    return false;
  }

  @override
  String get serviceHistoryButtonText {
    trigger.value; // Memancing Obx
    return "Update Riwayat Servis";
  }

  @override
  int get totalHargaSpareParts {
    trigger.value; // Memancing Obx
    return 150000;
  }
}

// ======================================================================
// 🔥 MULAI PENGUJIAN UI
// ======================================================================

void main() {
  setUpAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    Get.testMode = true;

    // Layar dibikin sangat panjang agar tombol di bawah tidak perlu di-scroll
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.window.physicalSizeTestValue = const Size(1080, 4000);
    binding.window.devicePixelRatioTestValue = 1.0;

    Get.put<ServiceHistoryController>(UltraFakeServiceHistoryController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Widget Testing - Service History View', () {
    testWidgets('Skenario 1: Memastikan form input dan data pengguna tampil', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: ServiceHistoryView()));

      expect(find.text('Riwayat Servis'), findsOneWidget);
      expect(find.text('Budi Santoso'), findsOneWidget);

      expect(find.text('Nama Mekanik'), findsOneWidget);
      expect(find.text('Diagnosis Masalah'), findsOneWidget);
      expect(find.text('Catatan'), findsOneWidget);
      expect(find.text('Pekerjaan Yang Telah Selesai'), findsOneWidget);

      // Verifikasi harga statis dari getter kita
      expect(find.text('Rp. 150.000'), findsOneWidget);
    });

    testWidgets('Skenario 2: Menguji interaksi pengetikan pada TextField', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: ServiceHistoryView()));

      final textFields = find.byType(TextField);
      expect(textFields.evaluate().length, greaterThanOrEqualTo(4));

      await tester.enterText(textFields.at(0), 'Mekanik Handal');
      await tester.pump();

      await tester.enterText(textFields.at(1), 'Kampas rem habis');
      await tester.pump();

      expect(find.text('Mekanik Handal'), findsOneWidget);
      expect(find.text('Kampas rem habis'), findsOneWidget);
    });

    testWidgets('Skenario 3: Memastikan tombol Update Riwayat Servis muncul', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: ServiceHistoryView()));

      // Kita langsung tembak cari teksnya saja agar lebih akurat
      final updateBtnText = find.text("Update Riwayat Servis");
      expect(updateBtnText, findsOneWidget);

      // Sentuh teks tombolnya secara langsung
      await tester.tap(updateBtnText, warnIfMissed: false);
      await tester.pumpAndSettle();
    });
  });
}
