import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/models/service_history_model.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/service_history/controllers/service_history_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ServiceHistoryController controller;

  // Dummy Data
  final dummyBooking = BookingsModel(id: 'BK-123');
  final dummyHistoryActive = ServiceHistoryModel(id: '1', status: 'dimulai');
  final dummyHistoryDone = ServiceHistoryModel(id: '2', status: 'selesai');

  setUp(() {
    CustomModal.isTest = true; // Flag untuk menandakan sedang testing
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing
    Get.testMode = true;
  });

  tearDown(() {
    Get.delete<ServiceHistoryController>(force: true);
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();
  });

  group(
    'ServiceHistoryController - handleServiceHistory V(G)=7 Unit Testing',
    () {
      // ==========================================
      // SKENARIO VALIDASI AWAL
      // ==========================================
      test('Path 1: Gagal jika selectedBooking null memicu Snackbar', () async {
        controller = ServiceHistoryController(provider: MockSuccessProvider());
        controller.selectedBooking.value = null;

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      // ==========================================
      // SKENARIO TAMBAH (CREATE)
      // ==========================================
      test('Path 2: Sukses Create riwayat servis', () async {
        controller = ServiceHistoryController(provider: MockSuccessProvider());
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.clear(); // Kosong = Create

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      test('Path 3: Gagal Create riwayat servis (isOk false)', () async {
        controller = ServiceHistoryController(provider: MockFailedProvider());
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.clear();

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      test('Path 4: Exception saat Create masuk blok catch', () async {
        controller = ServiceHistoryController(
          provider: MockExceptionProvider(),
        );
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.clear();

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      // ==========================================
      // SKENARIO UBAH (UPDATE)
      // ==========================================
      test('Path 5: Sukses Update riwayat servis (Status Dimulai)', () async {
        controller = ServiceHistoryController(provider: MockSuccessProvider());
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.value = [
          dummyHistoryActive,
        ]; // Ada isi = Update

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      test('Path 6: Gagal Update riwayat servis (isOk false)', () async {
        controller = ServiceHistoryController(provider: MockFailedProvider());
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.value = [dummyHistoryActive];

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });

      test('Path 7: Skip eksekusi API jika status sudah "Selesai"', () async {
        controller = ServiceHistoryController(provider: MockSuccessProvider());
        controller.selectedBooking.value = dummyBooking;
        controller.serviceHistory.value = [dummyHistoryDone]; // Status Selesai

        await controller.handleServiceHistory();

        expect(controller.isLoading.value, false);
      });
    },
  );
}

// ==========================================
// MOCK PROVIDER MANUAL KOMBISNASI
// ==========================================
class MockSuccessProvider extends ServiceHistoryProvider {
  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    return const Response(statusCode: 200, body: {'success': true});
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedProvider extends ServiceHistoryProvider {
  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    return const Response(statusCode: 400, body: {'success': false});
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    return const Response(statusCode: 400, body: {'success': false});
  }
}

class MockExceptionProvider extends ServiceHistoryProvider {
  @override
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    throw Exception('API Error');
  }

  @override
  Future<Response> updateServiceHistory(
    String id,
    Map<String, dynamic> data,
  ) async {
    throw Exception('API Error');
  }
}
