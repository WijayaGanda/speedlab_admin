import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

// TODO: Sesuaikan dengan path import Anda
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/service_list/controllers/service_list_controller.dart';
import 'package:speedlab_admin/app/modules/service_list/views/service_list_view.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('ServiceList Integration Testing - deleteService V(G)=3', () {
    setUp(() {
      Get.testMode = true;

      if (!Get.isRegistered<ServiceProvider>()) {
        Get.put<ServiceProvider>(MockSuccessServiceProvider());
      }

      Get.lazyPut(
        () =>
            ServiceListController(serviceProvider: Get.find<ServiceProvider>()),
      );
    });

    tearDown(() async {
      // HAPUS Get.closeAllSnackbars() di sini agar tidak memicu LateError & Ticker Leak
      Get.delete<ServiceListController>(force: true);
      Get.delete<ServiceProvider>(force: true);
      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildServiceListPage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const ServiceListView(),
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
    // PATH 1: Sukses Menghapus Layanan
    // ==========================================
    testWidgets('Path 1: Sukses menghapus layanan dan pindah ke dashboard', (
      tester,
    ) async {
      await buildServiceListPage(tester);

      final controller = Get.find<ServiceListController>();

      await controller.deleteService('123');

      // Tunggu delay mock (500ms) + biarkan animasi route bekerja natural
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Dashboard Page Dummy'), findsOneWidget);
    });

    // ==========================================
    // PATH 2: Gagal Respon API
    // ==========================================
    testWidgets('Path 2: API gagal memicu Snackbar Error', (tester) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockFailedServiceProvider());
      Get.delete<ServiceListController>(force: true);
      Get.lazyPut(
        () =>
            ServiceListController(serviceProvider: Get.find<ServiceProvider>()),
      );

      await buildServiceListPage(tester);

      final controller = Get.find<ServiceListController>();
      await controller.deleteService('123');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal menghapus layanan'), findsWidgets);

      // Biarkan snackbar hilang secara natural tanpa dipaksa tutup
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    // ==========================================
    // PATH 3: Terjadi Exception
    // ==========================================
    testWidgets('Path 3: Terjadi Exception memicu penanganan blok catch', (
      tester,
    ) async {
      Get.delete<ServiceProvider>(force: true);
      Get.put<ServiceProvider>(MockExceptionServiceProvider());
      Get.delete<ServiceListController>(force: true);
      Get.lazyPut(
        () =>
            ServiceListController(serviceProvider: Get.find<ServiceProvider>()),
      );

      await buildServiceListPage(tester);

      final controller = Get.find<ServiceListController>();
      await controller.deleteService('123');

      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal menghapus layanan'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class MockSuccessServiceProvider extends ServiceProvider {
  @override
  Future<Response> fetchServices() async {
    // PERBAIKAN: Tambahkan 'success': true
    return const Response(statusCode: 200, body: {'success': true, 'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedServiceProvider extends ServiceProvider {
  @override
  Future<Response> fetchServices() async {
    return const Response(statusCode: 200, body: {'success': true, 'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Response(statusCode: 400, body: {'success': false});
  }
}

class MockExceptionServiceProvider extends ServiceProvider {
  @override
  Future<Response> fetchServices() async {
    return const Response(statusCode: 200, body: {'success': true, 'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Koneksi Terputus');
  }
}
