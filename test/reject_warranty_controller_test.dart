import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// TODO: Sesuaikan dengan struktur folder proyek Anda
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/controllers/klaim_garansi_list_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late KlaimGaransiListController controller;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing
  });

  tearDown(() {
    Get.delete<KlaimGaransiListController>(force: true);
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  });

  group('KlaimGaransiListController - rejectWarranty V(G)=3 Unit Testing', () {
    // PATH 1
    test(
      'Path 1: Sukses menolak garansi dan memanggil fetchWarranties',
      () async {
        controller = KlaimGaransiListController(
          provider: MockSuccessRejectProvider(),
        );

        await controller.rejectWarranty(
          'WAR-123',
          'Rusak karena kesalahan pengguna',
        );

        expect(controller.isLoading.value, false);
      },
    );

    // PATH 2
    test('Path 2: Gagal dari API (isOk false) memicu error', () async {
      controller = KlaimGaransiListController(
        provider: MockFailedRejectProvider(),
      );

      await controller.rejectWarranty(
        'WAR-123',
        'Rusak karena kesalahan pengguna',
      );

      expect(controller.isLoading.value, false);
    });

    // PATH 3
    test('Path 3: Terjadi exception memicu blok catch', () async {
      controller = KlaimGaransiListController(
        provider: MockExceptionRejectProvider(),
      );

      await controller.rejectWarranty(
        'WAR-123',
        'Rusak karena kesalahan pengguna',
      );

      expect(controller.isLoading.value, false);
    });
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class MockSuccessRejectProvider extends WarrantyClaimProvider {
  @override
  Future<Response> fetchallWarrantyClaims() async {
    // Dipanggil saat onInit dan saat success reject
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> rejectWarranty(
    String? warrantyId,
    String status, {
    String? rejectionReason,
  }) async {
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedRejectProvider extends WarrantyClaimProvider {
  @override
  Future<Response> fetchallWarrantyClaims() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> rejectWarranty(
    String? warrantyId,
    String status, {
    String? rejectionReason,
  }) async {
    return const Response(
      statusCode: 400,
      body: {'success': false},
    ); // isOk false
  }
}

class MockExceptionRejectProvider extends WarrantyClaimProvider {
  @override
  Future<Response> fetchallWarrantyClaims() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> rejectWarranty(
    String? warrantyId,
    String status, {
    String? rejectionReason,
  }) async {
    throw Exception('Server Timeout');
  }
}
