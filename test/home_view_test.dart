import 'dart:io'; // 🔥 TAMBAHAN WAJIB UNTUK MEMBUKA KONEKSI INTERNET

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_admin/app/data/models/user_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/modules/home/controllers/home_controller.dart';
import 'package:speedlab_admin/app/modules/home/views/home_view.dart';
import 'package:speedlab_admin/app/modules/notification/controllers/notification_controller.dart';

// ======================================================================
// 1. FAKE SEDERHANA KHUSUS UI
// ======================================================================

class DummyUserModel implements UserModel {
  @override
  get name => 'Admin Skripsi';
  @override
  get avatar => null;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UltraFakeAuthService extends GetxService implements AuthService {
  @override
  var user = Rxn<UserModel>(DummyUserModel());
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class UltraFakeNotifProvider extends NotifProvider {}

class UltraFakeNotifController extends NotificationController {
  UltraFakeNotifController() : super(provider: UltraFakeNotifProvider());

  @override
  void onInit() {}

  var notifTrigger = 0.obs;
  @override
  int get unreadCount {
    notifTrigger.value;
    return 5;
  }
}

class UltraFakeHomeController extends HomeController {
  UltraFakeHomeController() : super(provider: BookingsProvider());

  @override
  void onInit() {}

  @override
  var isLoading = false.obs;

  var trigger = 0.obs;

  @override
  int get totalBookings {
    trigger.value;
    return 100;
  }

  @override
  int get menungguVerifikasi {
    trigger.value;
    return 10;
  }

  @override
  int get bookingsVerifikasi {
    trigger.value;
    return 20;
  }

  @override
  int get bookingsDikerjakan {
    trigger.value;
    return 30;
  }

  @override
  int get bookingsSelesai {
    trigger.value;
    return 40;
  }

  @override
  int get bookingsDibatalkan {
    trigger.value;
    return 0;
  }
}

// ======================================================================
// 2. MULAI WIDGET TESTING UI
// ======================================================================

void main() {
  // 🔥 BUKA GEMBOK INTERNET FLUTTER DI SINI 🔥
  setUpAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    Get.testMode = true;

    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.window.physicalSizeTestValue = const Size(1080, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;

    Get.put<AuthService>(UltraFakeAuthService());
    Get.put<NotifProvider>(UltraFakeNotifProvider());
    Get.put<NotificationController>(UltraFakeNotifController());
    Get.put<HomeController>(UltraFakeHomeController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Widget Test Memastikan antarmuka HomeView tampil sempurna', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: HomeView()));

    // Beri waktu 2 detik agar NetworkImage selesai mendownload gambar dari ui-avatars
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Selamat Datang,'), findsOneWidget);
    expect(find.text('Admin Skripsi'), findsOneWidget);
    expect(find.text('Statistik Booking'), findsOneWidget);

    expect(find.text('100'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);

    expect(find.text('5'), findsOneWidget);
  });
}
