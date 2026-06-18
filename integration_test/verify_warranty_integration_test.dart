import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speedlab_admin/app/data/models/warranty_model.dart';
import 'package:speedlab_admin/app/data/providers/warranty_claim.dart';
import 'package:speedlab_admin/app/modules/klaim_garansi_list/controllers/klaim_garansi_list_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

/// ===============================
/// SUCCESS PROVIDER
/// ===============================
class FakeSuccessWarrantyProvider extends WarrantyClaimProvider {
  @override
  Future<Response> verifyWarranties(String? warrantyId, String? status) async {
    return Response(statusCode: 200, body: {"success": true});
  }

  @override
  Future<Response> fetchallWarrantyClaims() async {
    return Response(statusCode: 200, body: {"data": []});
  }
}

/// ===============================
/// FAILED PROVIDER
/// ===============================
class FakeFailedWarrantyProvider extends WarrantyClaimProvider {
  @override
  Future<Response> verifyWarranties(String? warrantyId, String? status) async {
    return Response(statusCode: 400, body: {"success": false});
  }

  @override
  Future<Response> fetchallWarrantyClaims() async {
    return Response(statusCode: 200, body: {"data": []});
  }
}

/// ===============================
/// EXCEPTION PROVIDER
/// ===============================
class FakeExceptionWarrantyProvider extends WarrantyClaimProvider {
  @override
  Future<Response> verifyWarranties(String? warrantyId, String? status) async {
    throw Exception("Server Error");
  }

  @override
  Future<Response> fetchallWarrantyClaims() async {
    return Response(statusCode: 200, body: {"data": []});
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true;
  });

  group('Verify Warranty Integration Test', () {
    /// =========================================
    /// TC01 SUCCESS
    /// =========================================
    testWidgets('TC01 - Verify Warranty Success', (tester) async {
      final controller = KlaimGaransiListController(
        provider: FakeSuccessWarrantyProvider(),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await controller.verifyWarranty("WR001");
              },
              child: const Text("VERIFY"),
            ),
          ),
        ),
      );

      await tester.tap(find.text("VERIFY"));
      await tester.pumpAndSettle();

      expect(controller.isLoading.value, false);
    });

    /// =========================================
    /// TC02 FAILED
    /// =========================================
    testWidgets('TC02 - Verify Warranty Failed', (tester) async {
      final controller = KlaimGaransiListController(
        provider: FakeFailedWarrantyProvider(),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await controller.verifyWarranty("WR002");
              },
              child: const Text("VERIFY"),
            ),
          ),
        ),
      );

      await tester.tap(find.text("VERIFY"));
      await tester.pumpAndSettle();

      expect(controller.isLoading.value, false);
    });

    /// =========================================
    /// TC03 EXCEPTION
    /// =========================================
    testWidgets('TC03 - Verify Warranty Exception', (tester) async {
      final controller = KlaimGaransiListController(
        provider: FakeExceptionWarrantyProvider(),
      );

      await tester.pumpWidget(
        GetMaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                await controller.verifyWarranty("WR003");
              },
              child: const Text("VERIFY"),
            ),
          ),
        ),
      );

      await tester.tap(find.text("VERIFY"));
      await tester.pumpAndSettle();

      expect(controller.isLoading.value, false);
    });
  });
}
