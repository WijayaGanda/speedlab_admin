import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';

// TODO: Sesuaikan dengan path import Anda
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/booking_list/controllers/booking_list_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('BookingList Integration Testing - updateStatusBooking V(G)=3', () {
    setUp(() {
      Get.testMode = true;

      if (!Get.isRegistered<ServiceHistoryProvider>()) {
        Get.put<ServiceHistoryProvider>(DummyServiceHistoryProvider());
      }
      if (!Get.isRegistered<BookingsProvider>()) {
        Get.put<BookingsProvider>(MockSuccessBookingsProvider());
      }

      Get.lazyPut(
        () => BookingListController(
          provider: Get.find<BookingsProvider>(),
          serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
        ),
      );
    });

    tearDown(() async {
      Get.delete<BookingListController>(force: true);
      Get.delete<BookingsProvider>(force: true);
      Get.delete<ServiceHistoryProvider>(force: true);
      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildDummyPage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          // Dummy View sederhana agar Snackbar punya tempat untuk tampil
          home: const Scaffold(
            body: SafeArea(child: Text('Booking List View Dummy')),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // ==========================================
    // PATH 1: Sukses Update Status
    // ==========================================
    testWidgets('Path 1: Sukses mengupdate status memicu Snackbar Berhasil', (
      tester,
    ) async {
      await buildDummyPage(tester);

      final controller = Get.find<BookingListController>();

      // Picu langsung fungsinya
      await controller.updateStatusBooking('123', 'Selesai');

      // Tunggu delay mock API (500ms) + paksa frame + animasi masuk snackbar
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Berhasil'), findsWidgets);
      expect(find.text('Status booking berhasil diperbarui'), findsWidgets);

      // Biarkan animasi Snackbar selesai natural agar tidak Ticker Leak
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    // ==========================================
    // PATH 2: Gagal Respon API
    // ==========================================
    testWidgets('Path 2: API gagal memicu Snackbar Error API', (tester) async {
      Get.delete<BookingsProvider>(force: true);
      Get.put<BookingsProvider>(MockFailedBookingsProvider());
      Get.delete<BookingListController>(force: true);
      Get.lazyPut(
        () => BookingListController(
          provider: Get.find<BookingsProvider>(),
          serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
        ),
      );

      await buildDummyPage(tester);

      final controller = Get.find<BookingListController>();
      await controller.updateStatusBooking('123', 'Selesai');

      // Delay mock 1 detik
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      // Validasi judul dan pesan error berdasarkan respons API
      expect(find.text('Error API (400)'), findsWidgets);
      expect(find.text('Gagal dari server'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    // ==========================================
    // PATH 3: Terjadi Exception
    // ==========================================
    testWidgets('Path 3: Terjadi Exception memicu penanganan blok catch', (
      tester,
    ) async {
      Get.delete<BookingsProvider>(force: true);
      Get.put<BookingsProvider>(MockExceptionBookingsProvider());
      Get.delete<BookingListController>(force: true);
      Get.lazyPut(
        () => BookingListController(
          provider: Get.find<BookingsProvider>(),
          serviceHistoryProvider: Get.find<ServiceHistoryProvider>(),
        ),
      );

      await buildDummyPage(tester);

      final controller = Get.find<BookingListController>();
      await controller.updateStatusBooking('123', 'Selesai');

      // Delay mock 1 detik
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(controller.isLoading.value, false);
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Gagal memperbarui status booking'), findsWidgets);

      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class DummyServiceHistoryProvider extends ServiceHistoryProvider {}

class MockSuccessBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> updateStatusBooking(String id, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> updateStatusBooking(String id, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    return const Response(
      statusCode: 400,
      body: {'message': 'Gagal dari server'},
    );
  }
}

class MockExceptionBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> updateStatusBooking(String id, String status) async {
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Koneksi Terputus');
  }
}
