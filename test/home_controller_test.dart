import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';
// TODO: Sesuaikan dengan path project Anda
// import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';
// import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
// import 'package:speedlab_admin/app/data/services/auth_service.dart';

// Generate class MockBookingsProvider & MockAuthService
@GenerateNiceMocks([MockSpec<BookingsProvider>(), MockSpec<AuthService>()])
import 'home_controller_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeController controller;
  late MockBookingsProvider mockProvider;
  late MockAuthService mockAuthService;

  setUp(() {
    Get.testMode = true; // Mencegah error UI dari CustomSnackbar saat testing
    CustomSnackbar.isTesting = true; // Flag untuk menandakan sedang testing

    mockProvider = MockBookingsProvider();
    mockAuthService = MockAuthService();

    final dummyCallback = InternalFinalCallback<void>(callback: () {});

    when(mockAuthService.onStart).thenReturn(dummyCallback);
    when(mockAuthService.onDelete).thenReturn(dummyCallback);

    // when(mockFCMService.onStart).thenReturn(dummyCallback);
    // when(mockFCMService.onDelete).thenReturn(dummyCallback);

    // Wajib di-inject karena HomeController memanggil Get.find<AuthService>()
    Get.put<AuthService>(mockAuthService);

    controller = HomeController(provider: mockProvider);
  });

  tearDown(() {
    Get.delete<AuthService>(force: true);
  });

  group('HomeController - fetchAllBookings V(G)=3', () {
    // =========================
    // PATH 1: Sukses
    // =========================
    test('Path 1: Berhasil mengambil data (statusCode 200)', () async {
      // Arrange
      final mockResponse = Response(
        statusCode: 200,
        body: {
          'data': [
            {'id': 1, 'status': 'Menunggu Verifikasi'},
            {'id': 2, 'status': 'Terverifikasi'},
          ],
        },
      );
      when(
        mockProvider.fetchAllBookings(),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await controller.fetchAllBookings();

      // Assert
      expect(controller.bookings.isNotEmpty, true);
      expect(controller.totalBookings, 2);
      expect(controller.menungguVerifikasi, 1);
      expect(controller.isLoading.value, false);
    });

    // =========================
    // PATH 2: Gagal dari API
    // =========================
    test('Path 2: Gagal memanggil data dari API (statusCode != 200)', () async {
      // Arrange
      final mockResponse = const Response(statusCode: 400, body: {});
      when(
        mockProvider.fetchAllBookings(),
      ).thenAnswer((_) async => mockResponse);

      // Act
      await controller.fetchAllBookings();

      // Assert
      expect(controller.bookings.isEmpty, true);
      expect(controller.isLoading.value, false);
      // Logika masuk ke else dan memanggil CustomSnackbar.error
    });

    // =========================
    // PATH 3: Exception
    // =========================
    test('Path 3: Terjadi exception (masuk ke blok catch)', () async {
      // Arrange
      when(mockProvider.fetchAllBookings()).thenThrow(Exception('No Internet'));

      // Act
      await controller.fetchAllBookings();

      // Assert
      // Aplikasi tidak boleh crash karena sudah di-handle oleh try-catch
      expect(controller.bookings.isEmpty, true);
      expect(controller.isLoading.value, false);
    });
  });
}
