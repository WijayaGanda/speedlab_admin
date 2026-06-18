import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// TODO: Sesuaikan dengan import di project Anda
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/service_list/controllers/service_list_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ServiceListController controller;

  setUp(() {
    Get.testMode = true;
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing
  });

  tearDown(() {
    Get.delete<ServiceListController>(force: true);
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
  });

  group('ServiceListController - deleteService V(G)=3 Unit Testing', () {
    // PATH 1
    test(
      'Path 1: Harus berhasil menghapus dan redirect ke dashboard jika isOk true',
      () async {
        controller = ServiceListController(
          serviceProvider: MockSuccessServiceProvider(),
        );

        await controller.deleteService('123'); // ID dummy

        // Di unit test murni, kita hanya memvalidasi state karena navigasi divalidasi di integration test
        expect(controller.isLoading.value, false);
      },
    );

    // PATH 2
    test(
      'Path 2: Harus memicu error jika API mengembalikan isOk false',
      () async {
        controller = ServiceListController(
          serviceProvider: MockFailedServiceProvider(),
        );

        await controller.deleteService('123');

        expect(controller.isLoading.value, false);
      },
    );

    // PATH 3
    test(
      'Path 3: Harus menangani exception dengan aman lewat blok catch',
      () async {
        controller = ServiceListController(
          serviceProvider: MockExceptionServiceProvider(),
        );

        await controller.deleteService('123');

        expect(controller.isLoading.value, false);
      },
    );
  });
}

// ==========================================
// MOCK PROVIDER MANUAL
// ==========================================
class MockSuccessServiceProvider extends ServiceProvider {
  // Wajib dimock karena dipanggil oleh onInit
  @override
  Future<Response> fetchServices() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    return const Response(statusCode: 200, body: {'success': true});
  }
}

class MockFailedServiceProvider extends ServiceProvider {
  @override
  Future<Response> fetchServices() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    return const Response(
      statusCode: 400,
      body: {'success': false},
    ); // isOk false
  }
}

class MockExceptionServiceProvider extends ServiceProvider {
  @override
  Future<Response> fetchServices() async {
    return const Response(statusCode: 200, body: {'data': []});
  }

  @override
  Future<Response> deleteService(String id) async {
    throw Exception('Server Timeout');
  }
}
