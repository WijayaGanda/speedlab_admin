import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

// TODO: Sesuaikan dengan path import Anda
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/edit_service/controllers/edit_service_controller.dart';
import 'package:speedlab_admin/app/modules/edit_service/views/edit_service_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Dummy Model untuk disuntikkan ke Get.arguments
  final dummyService = ServiceModel(
    id: '99',
    name: 'Ganti Oli',
    description: 'Oli Mesin Bawaan',
    basePrice: 120000,
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

  group('EditService Integration Testing - updateService V(G)=4', () {
    setUp(() {
      Get.testMode = true;

      if (!Get.isRegistered<ServiceProvider>()) {
        Get.put<ServiceProvider>(MockSuccessServiceProvider());
      }

      Get.lazyPut(
        () => EditServiceController(provider: Get.find<ServiceProvider>()),
      );
    });

    tearDown(() async {
      if (Get.isSnackbarOpen) {
        Get.closeAllSnackbars();
      }
      Get.delete<EditServiceController>(force: true);
      Get.delete<ServiceProvider>(force: true);
      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildEditServicePage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          // 1. Mulai dari halaman dummy kosong agar tidak langsung crash
          home: const Scaffold(body: Text('Home Dummy')),
          getPages: [
            GetPage(
              name: '/edit-service',
              page: () => const EditServiceView(),
              // HAPUS arguments dari sini
            ),
            GetPage(
              name: '/dashboard',
              page: () => const Scaffold(body: Text('Dashboard Page Dummy')),
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      // 2. Navigasi secara manual sambil membawa argumen yang benar!
      Get.toNamed('/edit-service', arguments: dummyService);

      // Tunggu animasi transisi halaman selesai
      await tester.pumpAndSettle();
    }

    // ==========================================
    // PATH 1: Gagal Validasi Form
    // ==========================================
    testWidgets('Path 1: Memunculkan Snackbar Error jika field kosong', (
      tester,
    ) async {
      await buildEditServicePage(tester);

      final controller = Get.find<EditServiceController>();

      // Kosongkan salah satu field untuk memicu error
      controller.nameCtrl.text = '';

      await controller.updateService();

      // Tunggu Snackbar muncul (Get.snackbar bawaan)
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Error'), findsWidgets);
      expect(find.text('Semua field harus diisi'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    // ==========================================
    // PATH 2: Sukses Update Layanan
    // ==========================================
    testWidgets('Path 2: Sukses mengupdate layanan dan pindah halaman', (
      tester,
    ) async {
      await buildEditServicePage(tester);

      final controller = Get.find<EditServiceController>();
      // Data sudah terisi otomatis dari dummyService, kita ubah sedikit
      controller.nameCtrl.text = 'Ganti Oli Sintetik';

      await controller.updateService();

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('Dashboard Page Dummy'), findsOneWidget);
    });

    // ==========================================
    // PATH 3: Gagal Respon API
    // ==========================================
    testWidgets('Path 3: API gagal memicu Snackbar Error', (tester) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockFailedServiceProvider());
      Get.delete<EditServiceController>(force: true);
      Get.lazyPut(
        () => EditServiceController(provider: Get.find<ServiceProvider>()),
      );

      await buildEditServicePage(tester);

      final controller = Get.find<EditServiceController>();
      await controller.updateService();

      // Tunggu mock API (1 detik) + paksa frame + animasi masuk snackbar
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal memperbarui layanan'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    // ==========================================
    // PATH 4: Terjadi Exception
    // ==========================================
    testWidgets('Path 4: Terjadi Exception memicu penanganan blok catch', (
      tester,
    ) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockExceptionServiceProvider());
      Get.delete<EditServiceController>(force: true);
      Get.lazyPut(
        () => EditServiceController(provider: Get.find<ServiceProvider>()),
      );

      await buildEditServicePage(tester);

      final controller = Get.find<EditServiceController>();
      await controller.updateService();

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal memperbarui layanan'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 3));
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class MockSuccessServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Response(statusCode: 400, body: {'success': false});
  }
}

class MockExceptionServiceProvider extends ServiceProvider {
  @override
  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Koneksi Terputus');
  }
}
