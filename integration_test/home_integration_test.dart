import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_admin/app/modules/home/views/home_view.dart';
import 'package:speedlab_admin/app/modules/notification/controllers/notification_controller.dart';
// TODO: Sesuaikan import dengan struktur folder Speedlab Admin Anda
// import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
// import 'package:speedlab_admin/app/data/services/auth_service.dart';
// import 'package:speedlab_admin/app/modules/home/views/home_view.dart';
// import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Home Integration Testing - fetchAllBookings V(G)=3', () {
    setUp(() {
      Get.testMode = true;

      // ==========================================
      // 1. DAFTARKAN PROVIDER/SERVICE DULUAN
      // ==========================================
      if (!Get.isRegistered<AuthService>()) {
        Get.put<AuthService>(AuthService());
      }
      if (!Get.isRegistered<NotifProvider>()) {
        Get.put<NotifProvider>(MockSuccessNotifProvider());
      }
      if (!Get.isRegistered<BookingsProvider>()) {
        Get.put<BookingsProvider>(MockSuccessBookingsProvider());
      }

      // ==========================================
      // 2. DAFTARKAN CONTROLLER SETELAH PROVIDER ADA
      // ==========================================
      if (!Get.isRegistered<NotificationController>()) {
        // Ini sekarang aman karena NotifProvider sudah di-put di atas
        Get.put<NotificationController>(
          MockNotificationController(provider: Get.find<NotifProvider>()),
        );
      }

      Get.lazyPut(() => HomeController(provider: Get.find<BookingsProvider>()));
    });

    tearDown(() async {
      Get.delete<HomeController>(force: true);
      Get.delete<NotificationController>(force: true);
      Get.delete<BookingsProvider>(force: true);
      Get.delete<NotifProvider>(force: true);
      Get.delete<AuthService>(force: true);

      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildHomePage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const HomeView(),
          getPages: [
            GetPage(
              name: '/login',
              page: () => const Scaffold(body: Text('Login Page Dummy')),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
    }

    // =========================
    // PATH 1
    // Fetch Sukses (statusCode 200)
    // =========================
    testWidgets('Path 1: Fetch data sukses saat onInit', (tester) async {
      await buildHomePage(tester);

      final controller = Get.find<HomeController>();

      // Validasi State di Controller
      expect(controller.isLoading.value, false);
      expect(controller.bookings.length, 2);
      expect(controller.menungguVerifikasi, 1);

      // Validasi UI (Contoh: asumsikan text status muncul di layar)
      // Sesuaikan dengan teks / widget yang pasti dirender di HomeView Anda
      // expect(find.text('Menunggu Verifikasi'), findsWidgets);
    });

    // =========================
    // PATH 2
    // =========================
    testWidgets('Path 2: Response gagal memicu Snackbar Error', (tester) async {
      Get.delete<BookingsProvider>(force: true);
      Get.put<BookingsProvider>(MockFailedBookingsProvider());

      Get.delete<HomeController>(force: true);
      Get.lazyPut(() => HomeController(provider: Get.find<BookingsProvider>()));

      await buildHomePage(tester);

      // HAPUS BARIS INI:
      // await tester.pumpAndSettle(const Duration(seconds: 2));

      // GUNAKAN INI SEBAGAI GANTINYA:
      await tester.pump(const Duration(seconds: 1));

      // 2. Majukan waktu 500ms lagi agar animasi Snackbar masuk ke layar
      await tester.pump(const Duration(milliseconds: 500));
      final controller = Get.find<HomeController>();
      expect(controller.isLoading.value, false);
      expect(controller.bookings.isEmpty, true);

      // Sekarang teks pasti ditemukan karena Snackbar sedang tampil di layar
      expect(find.text('Error'), findsWidgets);
      expect(find.text('Failed to fetch bookings'), findsWidgets);

      // Bersihkan sisa animasi Snackbar agar tidak bocor ke test berikutnya
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    // =========================
    // PATH 3
    // =========================
    testWidgets('Path 3: Terjadi Exception memicu Snackbar Catch', (
      tester,
    ) async {
      Get.delete<BookingsProvider>(force: true);
      Get.put<BookingsProvider>(MockExceptionBookingsProvider());

      Get.delete<HomeController>(force: true);
      Get.lazyPut(() => HomeController(provider: Get.find<BookingsProvider>()));

      await buildHomePage(tester);

      // TANGKAP SNACKBAR SAAT MUNCUL
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final controller = Get.find<HomeController>();
      expect(controller.isLoading.value, false);
      expect(controller.bookings.isEmpty, true);

      expect(find.text('Error'), findsWidgets);
      expect(find.textContaining('An error occurred:'), findsWidgets);

      // Bersihkan sisa animasi
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });
}

// =========================
// MOCK SUCCESS
// =========================
class MockSuccessBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': [
          {'id': 101, 'status': 'Menunggu Verifikasi', 'customer_name': 'A'},
          {'id': 102, 'status': 'Selesai', 'customer_name': 'B'},
        ],
      },
    );
  }
}

// =========================
// MOCK FAILED
// =========================
class MockFailedBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    // Beri waktu 1 detik agar UI GetMaterialApp ter-render penuh sebelum snackbar dipanggil
    await Future.delayed(const Duration(seconds: 1));
    return const Response(
      statusCode: 400,
      body: {'success': false, 'message': 'Gagal mengambil data'},
    );
  }
}

// =========================
// MOCK EXCEPTION
// =========================
class MockExceptionBookingsProvider extends BookingsProvider {
  @override
  Future<Response> fetchAllBookings() async {
    // Beri waktu 1 detik
    await Future.delayed(const Duration(seconds: 1));
    throw Exception('Connection Timeout');
  }
}

// =========================
// MOCK NOTIF PROVIDER
// =========================
class MockSuccessNotifProvider extends NotifProvider {
  @override
  Future<Response> fetchNotifications() async {
    return const Response(statusCode: 200, body: {'success': true, 'data': []});
  }
}

// =========================
// MOCK NOTIF CONTROLLER
// =========================
class MockNotificationController extends NotificationController {
  // TAMBAHKAN BARIS INI: Meneruskan parameter ke parent (super)
  MockNotificationController({required super.provider});

  @override
  void onInit() {} // Kosongkan agar tidak otomatis fetch

  @override
  Future<void> fetchNotifications() async {} // Kosongkan

  @override
  int get unreadCount => _unreadCount.value;

  final _unreadCount = 0.obs;
  // Beri nilai default
}
