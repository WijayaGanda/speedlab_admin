import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/service_history/controllers/service_history_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final dummyBooking = BookingsModel(id: 'BK-123');
  final dummyHistoryActive = ServiceHistoryModel(id: '1', status: 'dimulai');

  group('ServiceHistory Integration Testing - handleServiceHistory V(G)=7', () {
    tearDown(() async {
      // HAPUS Get.back() dari sini agar tidak memicu error "contextless navigation"
      Get.delete<ServiceHistoryController>(force: true);
      Get.delete<ServiceHistoryProvider>(force: true);

      // Berikan jeda yang cukup panjang agar FocusManager dan sisa UI benar-benar mati
      await Future.delayed(const Duration(seconds: 1));
    });

    Future<void> buildDummyPage(
      WidgetTester tester,
      ServiceHistoryProvider provider,
    ) async {
      Get.put<ServiceHistoryProvider>(provider);

      await tester.pumpWidget(
        GetMaterialApp(
          initialRoute: '/home',
          getPages: [
            GetPage(
              name: '/home',
              page: () => const Scaffold(body: Text('Home')),
            ),
            GetPage(
              name: '/service-history',
              page: () {
                Get.put(
                  ServiceHistoryController(
                    provider: Get.find<ServiceHistoryProvider>(),
                  ),
                );
                return const Scaffold(body: Text('Dummy Page'));
              },
            ),
          ],
        ),
      );
      await tester.pumpAndSettle();

      Get.toNamed('/service-history', arguments: dummyBooking);
      await tester.pumpAndSettle();
    }

    // ==========================================
    // PATH 1: VALIDASI AWAL
    // ==========================================
    testWidgets(
      'Path 1: Gagal memicu Snackbar Error jika selectedBooking null',
      (tester) async {
        await buildDummyPage(tester, MockSuccessProvider());
        final controller = Get.find<ServiceHistoryController>();

        controller.selectedBooking.value = null;

        await controller.handleServiceHistory();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Error'), findsWidgets);
        expect(find.text('No booking selected'), findsWidgets);

        // Pastikan semua animasi selesai natural (5 detik cukup untuk Snackbar)
        await tester.pumpAndSettle(const Duration(seconds: 5));
      },
    );

    // ==========================================
    // PATH 2-4: CREATE (TAMBAH)
    // ==========================================
    testWidgets('Path 2: Sukses Create memunculkan Dialog Sukses', (
      tester,
    ) async {
      await buildDummyPage(tester, MockSuccessProvider());
      final controller = Get.find<ServiceHistoryController>();

      controller.selectedBooking.value = dummyBooking;
      controller.serviceHistory.clear();

      await controller.handleServiceHistory();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Success'), findsWidgets);
      expect(find.text('Riwayat Servis berhasil ditambahkan'), findsWidgets);

      // Tutup dialog secara manual lewat UI Tester agar aman
      if (find.text('OK').evaluate().isNotEmpty) {
        await tester.tap(find.text('OK').first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Path 3: Gagal Create memunculkan Dialog Error API', (
      tester,
    ) async {
      await buildDummyPage(tester, MockFailedProvider());
      final controller = Get.find<ServiceHistoryController>();

      controller.selectedBooking.value = dummyBooking;
      controller.serviceHistory.clear();

      await controller.handleServiceHistory();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal menambahkan riwayat servis'), findsWidgets);

      if (find.text('OK').evaluate().isNotEmpty) {
        await tester.tap(find.text('OK').first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets(
      'Path 4: Terjadi Exception saat Create memunculkan Dialog Exception',
      (tester) async {
        await buildDummyPage(tester, MockExceptionProvider());
        final controller = Get.find<ServiceHistoryController>();

        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.clear();

        await controller.handleServiceHistory();

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Error'), findsWidgets);
        expect(find.textContaining('An error occurred:'), findsWidgets);

        if (find.text('OK').evaluate().isNotEmpty) {
          await tester.tap(find.text('OK').first);
        }
        await tester.pumpAndSettle(const Duration(seconds: 2));
      },
    );

    // ==========================================
    // PATH 5-6: UPDATE (UBAH)
    // ==========================================
    testWidgets('Path 5: Sukses Update memunculkan Dialog Sukses', (
      tester,
    ) async {
      await buildDummyPage(tester, MockSuccessProvider());
      final controller = Get.find<ServiceHistoryController>();

      controller.selectedBooking.value = dummyBooking;
      controller.serviceHistory.value = [dummyHistoryActive];

      await controller.handleServiceHistory();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Success'), findsWidgets);
      expect(find.text('Riwayat Servis berhasil diperbarui'), findsWidgets);

      if (find.text('OK').evaluate().isNotEmpty) {
        await tester.tap(find.text('OK').first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Path 6: Gagal Update memunculkan Dialog Error API', (
      tester,
    ) async {
      await buildDummyPage(tester, MockFailedProvider());
      final controller = Get.find<ServiceHistoryController>();

      controller.selectedBooking.value = dummyBooking;
      controller.serviceHistory.value = [dummyHistoryActive];

      await controller.handleServiceHistory();

      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal memperbarui riwayat servis'), findsWidgets);

      if (find.text('OK').evaluate().isNotEmpty) {
        await tester.tap(find.text('OK').first);
      }
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL DENGAN DELAY
// ==========================================
class MockSuccessProvider extends ServiceHistoryProvider {
  @override
  Future<Response> getServiceHistory(String bookingId) async {
    throw Exception('Silent Bypass');
  }

  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedProvider extends ServiceHistoryProvider {
  @override
  Future<Response> getServiceHistory(String bookingId) async {
    throw Exception('Silent Bypass');
  }

  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 400, body: {'success': false});
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 400, body: {'success': false});
  }
}

class MockExceptionProvider extends ServiceHistoryProvider {
  @override
  Future<Response> getServiceHistory(String bookingId) async {
    throw Exception('Silent Bypass');
  }

  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('Koneksi Putus');
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    throw Exception('Koneksi Putus');
  }
}
