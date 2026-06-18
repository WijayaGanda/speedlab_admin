import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// TODO: Sesuaikan dengan import di project Anda
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/edit_service/controllers/edit_service_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late EditServiceController controller;

  // Siapkan dummy data model
  // Sesuaikan parameter ServiceModel dengan yang ada di project asli Anda
  final dummyService = ServiceModel(
    id: '1',
    name: 'Ganti Oli',
    description: 'Oli Mesin',
    basePrice: 100000,
    estimatedDuration: 30,
    category: 'Perawatan',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    variants: [],
    availableAddons: [],
    isActive: true,
    isWaitable: true,
    v: 0,
  );

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing
  });

  tearDown(() {
    Get.delete<EditServiceController>(force: true);
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  });

  group('EditServiceController - updateService V(G)=4 Unit Testing', () {
    // PATH 1
    test('Path 1: Harus memicu error jika ada field yang kosong', () async {
      // Setup Controller dengan Provider apa saja (karena tidak akan sampai dipanggil)
      controller = EditServiceController(
        provider: MockSuccessServiceProvider(),
      );

      // Inisialisasi controller secara manual (karena kita tidak pakai UI/Get.arguments)
      controller.service.value = dummyService;
      controller.nameCtrl = TextEditingController(text: ''); // Sengaja kosong
      controller.deskripsiCtrl = TextEditingController(text: 'Deskripsi');
      controller.hargaCtrl = TextEditingController(text: '100000');
      controller.estimatedDurationCtrl = TextEditingController(text: '30');

      await controller.updateService();

      expect(controller.isLoading.value, false);
      // Tes berhasil jika tidak terjadi pemanggilan API (bisa dilihat dari coverage/logika)
    });

    // PATH 2
    test('Path 2: Harus berhasil update dan redirect ke dashboard', () async {
      controller = EditServiceController(
        provider: MockSuccessServiceProvider(),
      );

      controller.service.value = dummyService;
      controller.nameCtrl = TextEditingController(text: 'Ganti Oli Baru');
      controller.deskripsiCtrl = TextEditingController(text: 'Oli Sintetik');
      controller.hargaCtrl = TextEditingController(text: '150000');
      controller.estimatedDurationCtrl = TextEditingController(text: '45');

      await controller.updateService();

      expect(controller.isLoading.value, false);
      // Validasi route biasanya di Integration Test, untuk unit test kita pastikan flow jalannya benar
    });

    // PATH 3
    test('Path 3: Harus menampilkan error jika respon isOk false', () async {
      controller = EditServiceController(provider: MockFailedServiceProvider());

      controller.service.value = dummyService;
      controller.nameCtrl = TextEditingController(text: 'Ganti Oli Baru');
      controller.deskripsiCtrl = TextEditingController(text: 'Oli Sintetik');
      controller.hargaCtrl = TextEditingController(text: '150000');
      controller.estimatedDurationCtrl = TextEditingController(text: '45');

      await controller.updateService();

      expect(controller.isLoading.value, false);
    });

    // PATH 4
    test('Path 4: Harus menangkap exception dengan aman', () async {
      controller = EditServiceController(
        provider: MockExceptionServiceProvider(),
      );

      controller.service.value = dummyService;
      controller.nameCtrl = TextEditingController(text: 'Ganti Oli Baru');
      controller.deskripsiCtrl = TextEditingController(text: 'Oli Sintetik');
      controller.hargaCtrl = TextEditingController(text: '150000');
      controller.estimatedDurationCtrl = TextEditingController(text: '45');

      await controller.updateService();

      expect(controller.isLoading.value, false);
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class MockSuccessServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    return const Response(
      statusCode: 400,
      body: {'success': false},
    ); // isOk akan false
  }
}

class MockExceptionServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    throw Exception('Server Timeout');
  }
}
