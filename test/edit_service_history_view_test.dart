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
// 🔥 FAKE CONTROLLER KHUSUS MODE UPDATE
// ======================================================================

class FakeUpdateServiceHistoryController extends ServiceHistoryController {
  FakeUpdateServiceHistoryController()
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
  @override
  var spareParts = <Map<String, String>>[].obs;

  // Pancingan Obx
  var trigger = 0.obs;

  @override
  bool get isFormDisabled {
    trigger.value;
    return false; // Form masih bisa diedit karena status belum 'Selesai'
  }

  @override
  String get serviceHistoryButtonText {
    trigger.value;
    return "Update Riwayat Servis";
  }

  @override
  int get totalHargaSpareParts {
    trigger.value;
    return 0;
  }

  @override
  var selectedBooking = Rxn<BookingsModel>(
    BookingsModel.fromJson({
      'id': 'BK-555',
      'userId': {'name': 'Bapak Update'},
    }),
  );

  // 🔥 KUNCI UTAMA: KITA ISI DATA SERVICE HISTORY-NYA 🔥
  @override
  var serviceHistory =
      <ServiceHistoryModel>[
        ServiceHistoryModel(
          id: "1",
          bookingId: <String, dynamic>{"id": "BK-555"},
          mechanicName: 'Mekanik Awal',
          diagnosis: 'Ganti Oli',
          notes: 'Oli mesin',
          workDone: 'Sedang membuang oli',
          status: 'Sedang Dikerjakan', // Status ini membuat form tetap terbuka
        ),
      ].obs;

  // Variabel untuk membuktikan bahwa UI berhasil memanggil fungsi ini
  bool isUpdateFunctionCalled = false;

  // Kita bajak fungsi aslinya agar tidak menembak server
  @override
  Future<void> handleServiceHistory() async {
    isUpdateFunctionCalled = true;
  }
}

// ======================================================================
// 🔥 MULAI PENGUJIAN UI
// ======================================================================

void main() {
  late FakeUpdateServiceHistoryController fakeController;

  setUpAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    Get.testMode = true;

    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    // Layar panjang agar tombol tidak tersembunyi
    binding.window.physicalSizeTestValue = const Size(1080, 4000);
    binding.window.devicePixelRatioTestValue = 1.0;

    fakeController = FakeUpdateServiceHistoryController();
    Get.put<ServiceHistoryController>(fakeController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Widget Testing - Mode Update Service History', () {
    testWidgets(
      'Skenario Update: Memastikan tombol Update berfungsi dan memanggil Controller',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: ServiceHistoryView()),
        );

        // 1. Pastikan data pengguna yang sedang diupdate tampil
        expect(find.text('Bapak Update'), findsOneWidget);

        // 2. Cari ElevatedButton khusus untuk Update
        final updateBtnText = find.text("Update Riwayat Servis");
        expect(updateBtnText, findsOneWidget);

        // 3. Sentuh tombol update tersebut
        await tester.tap(updateBtnText, warnIfMissed: false);
        await tester.pumpAndSettle();

        // 4. Verifikasi Mutlak: Apakah sentuhan di UI berhasil menyetrum fungsi di Controller?
        expect(fakeController.isUpdateFunctionCalled, true);
      },
    );
  });
}
