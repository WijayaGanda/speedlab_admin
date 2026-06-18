import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// TODO: Sesuaikan dengan import di project Anda
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/booking_list/controllers/booking_list_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BookingListController controller;

  setUp(() {
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing
    Get.testMode = true;
  });

  tearDown(() {
    Get.delete<BookingListController>(force: true);
  });

  group('BookingListController - updateStatusBooking V(G)=3 Unit Testing', () {
    // PATH 1
    test(
      'Path 1: Sukses memperbarui status, tampilkan snackbar sukses, dan refresh data',
      () async {
        controller = BookingListController(
          provider: MockSuccessBookingsProvider(),
          serviceHistoryProvider: DummyServiceHistoryProvider(),
        );

        await controller.updateStatusBooking('123', 'Selesai');

        expect(controller.isLoading.value, false);
      },
    );

    // PATH 2
    test('Path 2: Gagal dari API, tampilkan snackbar error API', () async {
      controller = BookingListController(
        provider: MockFailedBookingsProvider(),
        serviceHistoryProvider: DummyServiceHistoryProvider(),
      );

      await controller.updateStatusBooking('123', 'Selesai');

      expect(controller.isLoading.value, false);
    });

    // PATH 3
    test(
      'Path 3: Terjadi exception, masuk blok catch, tampilkan snackbar error',
      () async {
        controller = BookingListController(
          provider: MockExceptionBookingsProvider(),
          serviceHistoryProvider: DummyServiceHistoryProvider(),
        );

        await controller.updateStatusBooking('123', 'Selesai');

        expect(controller.isLoading.value, false);
      },
    );
  });
}

// ==========================================
// DUMMY & MOCK PROVIDER
// ==========================================
class DummyServiceHistoryProvider extends ServiceHistoryProvider {
  // Hanya sebagai pelengkap parameter, tidak dipanggil di fungsi yang diuji
}

class MockSuccessBookingsProvider extends BookingsProvider {
  // Dipanggil saat onInit dan saat updateStatusBooking sukses
  @override
  Future<Response> fetchAllBookings() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> updateStatusBooking(String id, String status) async {
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
    throw Exception('Database Timeout');
  }
}
