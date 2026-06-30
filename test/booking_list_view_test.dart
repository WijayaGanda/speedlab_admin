import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Sesuaikan import ini dengan struktur folder Anda
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/providers/service_history_provider.dart';
import 'package:speedlab_admin/app/modules/booking_list/controllers/booking_list_controller.dart';
import 'package:speedlab_admin/app/modules/booking_list/views/booking_list_view.dart';

// ======================================================================
// 🔥 FAKE CONTROLLER SUPER SIMPEL KHUSUS UI
// ======================================================================

class UltraFakeBookingListController extends BookingListController {
  // Kita bypass providernya pakai yang kosong karena tidak akan kita pakai
  UltraFakeBookingListController()
    : super(
        provider: BookingsProvider(),
        serviceHistoryProvider: ServiceHistoryProvider(),
      );

  @override
  void onInit() {} // Matikan API saat layar dibuka

  @override
  var isLoading = false.obs;

  // 🔥 KITA MANIPULASI DATANYA DI SINI 🔥
  @override
  List<BookingsModel> getBookingsByStatus(String status) {
    // Jika tab-nya 'Menunggu Verifikasi', kita beri 1 data palsu
    if (status == 'Menunggu Verifikasi') {
      return [
        BookingsModel.fromJson({
          'id': 'BK-12345678',
          'status': 'Menunggu Verifikasi',
          'totalPrice': 150000,
        }),
      ];
    }
    // Untuk tab lainnya, biarkan kosong agar kita bisa lihat tulisan "Belum Ada Penugasan!"
    return [];
  }

  // Kita override fungsi format teks agar tidak error karena datanya kosongan
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

  testWidgets('Widget Test UI Riwayat Booking (Layar Kosong & Layar Terisi)', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const GetMaterialApp(home: BookingListView()));

    // 2. Verifikasi Komponen Dasar (AppBar & TabBar)
    expect(find.text('Riwayat Booking'), findsOneWidget);
    expect(find.byTooltip('Filter'), findsOneWidget);

    await tester.tap(find.byTooltip('Filter'));
    await tester.pumpAndSettle();

    expect(find.text('Filter Booking'), findsOneWidget);
    expect(find.text('Cari booking...'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);

    // 🔥 PERBAIKAN DI SINI: Kita beritahu mesin bahwa ada 2 tulisan ini (Tab & Kartu)
    expect(find.text('Menunggu Verifikasi'), findsNWidgets(2));

    expect(find.text('Selesai'), findsOneWidget);

    // 3. Verifikasi Tab 1 (Ada Datanya)
    expect(find.text('ID: #BK-1234'), findsOneWidget);
    expect(find.text('Honda Vario 2022 - B 1234 ABC'), findsOneWidget);
    expect(find.text('Servis CVT'), findsOneWidget);
    expect(find.text('Total: Rp 150.000'), findsOneWidget);

    expect(find.text('Detail'), findsOneWidget);
    expect(find.text('Aksi'), findsOneWidget);

    // 4. Verifikasi Tab 2 (Layar Kosong)
    // Beri peringatan false agar tidak error kalau jari virtual agak meleset
    await tester.tap(find.text('Terverifikasi'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Belum Ada Penugasan!'), findsOneWidget);
    expect(
      find.text('Tidak ada booking dengan status\n"Terverifikasi"'),
      findsOneWidget,
    );
  });
}
