import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/booking_list/controllers/booking_list_controller.dart';
import 'package:speedlab_admin/app/modules/booking_list/views/booking_list_view.dart';

// ======================================================================
// 🔥 FAKE CONTROLLER SUPER SIMPEL KHUSUS UI
// ======================================================================

class UltraFakeBookingListController extends BookingListController {
  UltraFakeBookingListController()
    : super(
        provider: BookingsProvider(),
        serviceHistoryProvider: ServiceHistoryProvider(),
      );

  @override
  void onInit() {}

  @override
  var isLoading = false.obs;

  @override
  List<BookingsModel> getBookingsByStatus(String status) {
    if (status == 'Menunggu Verifikasi') {
      return [
        BookingsModel.fromJson({
          'id': 'BK-12345678',
          'status':
              'Menunggu Verifikasi', // Status ini yang memicu tombol Aksi spesifik
          'totalPrice': 150000,
        }),
      ];
    }
    return [];
  }

  @override
  String formatBookingId(String? id) => '#BK-1234';
  @override
  String formatPrice(int? price) => 'Rp 150.000';
  @override
  String getMotorcycleInfo(BookingsModel booking) =>
      'Honda Vario 2022 - B 1234 ABC';
  @override
  String getServicesInfo(BookingsModel booking) => 'Servis CVT';
  @override
  String formatDateTime(BookingsModel booking) => '20 Mei 2026, 10:00 WIB';
}

// ======================================================================
// 🔥 MULAI PENGUJIAN UI
// ======================================================================

void main() {
  setUp(() {
    Get.testMode = true;

    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.window.physicalSizeTestValue = const Size(1080, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;

    Get.put<BookingListController>(UltraFakeBookingListController());
  });

  tearDown(() {
    Get.reset();
  });

  group('Widget Testing - Booking List View', () {
    testWidgets(
      'Skenario 1: UI Riwayat Booking (Layar Kosong & Layar Terisi)',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: BookingListView()));

        expect(find.text('Riwayat Booking'), findsOneWidget);
        expect(find.text('Menunggu Verifikasi'), findsNWidgets(2));
        expect(find.text('Selesai'), findsOneWidget);

        expect(find.text('ID: #BK-1234'), findsOneWidget);
        expect(find.text('Honda Vario 2022 - B 1234 ABC'), findsOneWidget);
        expect(find.text('Servis CVT'), findsOneWidget);
        expect(find.text('Total: Rp 150.000'), findsOneWidget);

        expect(find.text('Detail'), findsOneWidget);
        expect(find.text('Aksi'), findsOneWidget);

        await tester.tap(find.text('Terverifikasi'), warnIfMissed: false);
        await tester.pumpAndSettle();

        expect(find.text('Belum Ada Penugasan!'), findsOneWidget);
        expect(
          find.text('Tidak ada booking dengan status\n"Terverifikasi"'),
          findsOneWidget,
        );
      },
    );

    // 🔥 SKENARIO BARU KHUSUS UNTUK INTERAKSI BOTTOM SHEET 🔥
    testWidgets('Skenario 2: Menekan tombol Aksi memunculkan Action Sheet', (
      WidgetTester tester,
    ) async {
      // 1. Gambar halamannya di memori
      await tester.pumpWidget(const GetMaterialApp(home: BookingListView()));

      // 2. Cari tombol "Aksi" yang ada di kartu booking
      final btnAksi = find.text('Aksi');
      expect(btnAksi, findsOneWidget);

      // 3. Simulasikan ketukan jari pada tombol tersebut
      await tester.tap(btnAksi);

      // 4. Beri waktu agar animasi BottomSheet muncul dari bawah layar
      await tester.pumpAndSettle();

      // 5. Verifikasi komponen di dalam BottomSheet / Modal!
      // Berdasarkan kode Anda, jika statusnya 'Menunggu Verifikasi',
      // maka judulnya 'Pilih Aksi' dan menu di dalamnya ada 2:
      expect(find.text('Pilih Aksi'), findsOneWidget);
      expect(find.text('Batalkan Booking'), findsOneWidget);
      expect(find.text('Verifikasi Booking'), findsOneWidget);
    });
  });
}
