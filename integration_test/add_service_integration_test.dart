import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

// TODO: Sesuaikan dengan path import Anda
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/add_service/controllers/add_service_controller.dart';
import 'package:speedlab_admin/app/modules/add_service/views/add_service_view.dart';
import 'package:speedlab_admin/app/modules/dashboard/controllers/dashboard_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AddService Integration Testing - addService V(G)=4', () {
    setUp(() {
      Get.testMode = true;

      // Suntik Dummy Dashboard
      if (!Get.isRegistered<DashboardController>()) {
        Get.put<DashboardController>(DummyDashboardController());
      }

      // Default Provider Sukses
      if (!Get.isRegistered<ServiceProvider>()) {
        Get.put<ServiceProvider>(MockSuccessServiceProvider());
      }

      Get.lazyPut(
        () => AddServiceController(provider: Get.find<ServiceProvider>()),
      );
    });

    tearDown(() async {
      // 1. BERSIHKAN ANTREAN SNACKBAR GLOBAL GETX
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }

      Get.delete<AddServiceController>(force: true);
      Get.delete<ServiceProvider>(force: true);
      Get.delete<DashboardController>(force: true);
      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildAddServicePage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const AddServiceView(),
          getPages: [
            GetPage(
              name: '/dashboard',
              page: () => const Scaffold(body: Text('Dashboard Page Dummy')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();
    }

    // ==========================================
    // PATH 1: Gagal Validasi Form
    // ==========================================
    testWidgets('Path 1: Memunculkan Dialog Error jika field kosong', (
      tester,
    ) async {
      await buildAddServicePage(tester);

      final controller = Get.find<AddServiceController>();
      controller.nameCtrl.text = ''; // Kosong

      await controller.addService();

      // Tunggu dialog muncul
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Error'), findsWidgets);
      expect(find.text('Semua field utama harus diisi'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ==========================================
    // PATH 2: Sukses Tambah Layanan
    // ==========================================
    testWidgets('Path 2: Sukses menambahkan layanan dan pindah halaman', (
      tester,
    ) async {
      await buildAddServicePage(tester);

      final controller = Get.find<AddServiceController>();
      controller.nameCtrl.text = 'Remap Stage 1';
      controller.deskripsiCtrl.text = 'Optimasi ECU';
      controller.estimatedDurationCtrl.text = '60';
      controller.hargaCtrl.text = '1500000';

      await controller.addService();

      // Tunggu delay mock (500ms) + transisi halaman ke /dashboard
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verifikasi sampai ke dashboard
      expect(find.text('Dashboard Page Dummy'), findsOneWidget);
    });

    // ==========================================
    // PATH 3: Gagal Respon API
    // ==========================================
    // ==========================================
    // PATH 3: Gagal Respon API
    // ==========================================
    testWidgets('Path 3: API gagal memicu Snackbar Error', (tester) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockFailedServiceProvider());
      Get.delete<AddServiceController>(force: true);
      Get.lazyPut(
        () => AddServiceController(provider: Get.find<ServiceProvider>()),
      );

      await buildAddServicePage(tester);

      final controller = Get.find<AddServiceController>();
      controller.nameCtrl.text = 'Remap Stage 1';
      controller.deskripsiCtrl.text = 'Optimasi ECU';
      controller.estimatedDurationCtrl.text = '60';

      await controller.addService();

      // 1. Tunggu waktu mock API selesai (1 detik)
      await tester.pump(const Duration(seconds: 1));

      // 2. PAKSA TRIGGER FRAME UI (Sangat penting agar Snackbar didaftarkan ke layar)
      await tester.pump();

      // 3. Majukan waktu 500ms agar animasi masuk Snackbar selesai
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.textContaining('Gagal menambahkan layanan:'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
    // ==========================================
    // PATH 4: Terjadi Exception
    // ==========================================
    testWidgets('Path 4: Terjadi Exception memicu penanganan blok catch', (
      tester,
    ) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockExceptionServiceProvider());
      Get.delete<AddServiceController>(force: true);
      Get.lazyPut(
        () => AddServiceController(provider: Get.find<ServiceProvider>()),
      );

      await buildAddServicePage(tester);

      final controller = Get.find<AddServiceController>();
      controller.nameCtrl.text = 'Remap Stage 1';
      controller.deskripsiCtrl.text = 'Optimasi ECU';
      controller.estimatedDurationCtrl.text = '60';

      await controller.addService();

      // Tunggu mock (1 detik) + animasi snackbar (500ms)
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

// ==========================================
// DUMMY & MOCK KELAS
// ==========================================
class DummyDashboardController extends DashboardController {
  @override
  void onInit() {
    // Kosongkan agar aman dari eksekusi background GetX
  }
}

class MockSuccessServiceProvider extends ServiceProvider {
  @override
  Future<Response> createFullServices(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedServiceProvider extends ServiceProvider {
  @override
  Future<Response> createFullServices(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Response(statusCode: 400, body: {'success': false});
  }
}

class MockExceptionServiceProvider extends ServiceProvider {
  @override
  Future<Response> createFullServices(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Timeout Connection');
  }
}
