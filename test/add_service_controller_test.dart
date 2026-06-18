import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get.dart';

// TODO: Sesuaikan dengan struktur import di project Anda
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/add_service/controllers/add_service_controller.dart';
import 'package:speedlab_admin/app/modules/dashboard/controllers/dashboard_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

@GenerateMocks([ServiceProvider])
import 'add_service_controller_test.mocks.dart';

// DUMMY MANUAL: Bebas dari error "FakeUsedError onStart" Mockito
class DummyDashboardController extends DashboardController {
  @override
  void onInit() {
    // Kosongkan agar aman dari eksekusi background GetX
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AddServiceController controller;
  late MockServiceProvider mockProvider;

  setUp(() {
    Get.testMode = true;
    CustomModal.isTest = true; // Flag untuk menandakan sedang testing
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing

    // 1. Suntikkan Dummy DashboardController MANUAL
    if (!Get.isRegistered<DashboardController>()) {
      Get.put<DashboardController>(DummyDashboardController());
    }

    // 2. Siapkan Mock Provider
    mockProvider = MockServiceProvider();

    // 3. Inisialisasi Controller yang diuji
    controller = AddServiceController(provider: mockProvider);

    // Inisialisasi controller text agar tidak null
    controller.nameCtrl = TextEditingController();
    controller.deskripsiCtrl = TextEditingController();
    controller.hargaCtrl = TextEditingController();
    controller.estimatedDurationCtrl = TextEditingController();
  });

  tearDown(() {
    Get.delete<AddServiceController>(force: true);
    Get.delete<DashboardController>(force: true);
  });

  group('AddServiceController - addService V(G)=4 Unit Testing', () {
    // PATH 1
    test('Path 1: Harus memicu Error Dialog jika field utama kosong', () async {
      controller.nameCtrl.text = '';
      controller.deskripsiCtrl.text = 'Deskripsi';
      controller.estimatedDurationCtrl.text = '60';

      await controller.addService();

      expect(controller.isLoading.value, false);
      verifyNever(mockProvider.createFullServices(any));
    });

    // PATH 2
    test(
      'Path 2: Harus sukses menambah layanan jika respon API 200/isOk',
      () async {
        controller.nameCtrl.text = 'Remap';
        controller.deskripsiCtrl.text = 'Deskripsi Remap';
        controller.estimatedDurationCtrl.text = '45';
        controller.hargaCtrl.text = '500000';

        final mockResponse = Response(statusCode: 200, body: {'success': true});
        when(
          mockProvider.createFullServices(any),
        ).thenAnswer((_) async => mockResponse);

        await controller.addService();

        expect(controller.isLoading.value, false);
        expect(controller.nameCtrl.text.isEmpty, true);
      },
    );

    // PATH 3
    test(
      'Path 3: Harus memicu error jika respon API gagal (isOk == false)',
      () async {
        controller.nameCtrl.text = 'Remap';
        controller.deskripsiCtrl.text = 'Deskripsi Remap';
        controller.estimatedDurationCtrl.text = '45';

        final mockResponse = const Response(
          statusCode: 400,
          body: {'success': false},
        );
        when(
          mockProvider.createFullServices(any),
        ).thenAnswer((_) async => mockResponse);

        await controller.addService();

        expect(controller.isLoading.value, false);
        expect(
          controller.nameCtrl.text.isNotEmpty,
          true,
        ); // Form tidak dibersihkan
      },
    );

    // PATH 4
    test(
      'Path 4: Harus menangani exception dengan aman lewat blok catch',
      () async {
        controller.nameCtrl.text = 'Remap';
        controller.deskripsiCtrl.text = 'Deskripsi Remap';
        controller.estimatedDurationCtrl.text = '45';

        when(
          mockProvider.createFullServices(any),
        ).thenThrow(Exception('Database Error'));

        await controller.addService();

        expect(controller.isLoading.value, false);
        expect(controller.nameCtrl.text.isNotEmpty, true);
      },
    );
  });
}
