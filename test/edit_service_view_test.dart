import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Sesuaikan import ini dengan struktur folder Anda
import 'package:speedlab_admin/app/data/models/service_model.dart';
import 'package:speedlab_admin/app/data/providers/service_provider.dart';
import 'package:speedlab_admin/app/modules/edit_service/controllers/edit_service_controller.dart';
import 'package:speedlab_admin/app/modules/edit_service/views/edit_service_view.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';

// ======================================================================
// 🔥 1. FAKE PROVIDER & FAKE MODEL
// ======================================================================

class FakeServiceProvider extends ServiceProvider {
  bool isApiCalled = false;
  Map<String, dynamic>? savedPayload;

  @override
  Future<Response> updateServices(
    String id,
    Map<String, dynamic> payload,
  ) async {
    isApiCalled = true;
    savedPayload = payload;
    // Mengembalikan 400 agar tidak memicu Get.offAllNamed('/dashboard')
    // Sehingga tidak menimbulkan error rute tidak ditemukan di dalam Widget Test.
    return const Response(
      statusCode: 400,
      body: {'message': 'Gagal disengaja'},
    );
  }
}

// Kita buat model data "Koper" tiruan agar Get.arguments tidak bernilai null
class DummyServiceModel implements ServiceModel {
  @override
  get id => '99'; // ID Layanan
  @override
  get name => 'Servis AC Mobil';
  @override
  get description => 'Membersihkan filter dan freon';
  @override
  get basePrice => 200000.0;
  @override
  get estimatedDuration => 60;

  // Baris ajaib agar class tidak protes bila ada properti model lain yang tidak kita tulis
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
// ======================================================================

void main() {
  late FakeServiceProvider fakeServiceProvider;

  setUp(() {
    Get.testMode = true;

    // Perbesar layar agar CustomButton tidak "tersembunyi" di bawah
    TestWidgetsFlutterBinding.ensureInitialized();
    final binding = TestWidgetsFlutterBinding.instance;
    binding.window.physicalSizeTestValue = const Size(800, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;

    fakeServiceProvider = FakeServiceProvider();
  });

  tearDown(() {
    Get.reset();
  });

  // Fungsi khusus untuk me-load halaman dengan simulasi Get.arguments
  Future<void> loadEditPage(WidgetTester tester) async {
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/home',
        getPages: [
          GetPage(name: '/home', page: () => const Scaffold()),
          GetPage(
            name: '/edit',
            page: () => const EditServiceView(),
            binding: BindingsBuilder(() {
              Get.put(EditServiceController(provider: fakeServiceProvider));
            }),
          ),
        ],
      ),
    );

    // Simulasikan masuk ke halaman Edit membawa argumen data
    Get.toNamed('/edit', arguments: DummyServiceModel());
    await tester.pumpAndSettle(); // Tunggu animasi pindah layar selesai
  }

  group('Widget Testing - EditServiceView (Tanpa Mockito)', () {
    testWidgets(
      'Skenario 1: Memastikan data awal dari Get.arguments otomatis masuk ke TextField',
      (WidgetTester tester) async {
        await loadEditPage(tester);

        // Pastikan ada 4 buah CustomTextField
        expect(find.byType(CustomTextField), findsNWidgets(4));

        // Verifikasi: Apakah tulisan 'Servis AC Mobil' langsung terisi di layar?
        // Jika iya, berarti fitur Edit Service sudah berfungsi sempurna mengambil data lama.
        expect(find.text('Servis AC Mobil'), findsOneWidget);
        expect(find.text('Membersihkan filter dan freon'), findsOneWidget);
        expect(find.text('200000.0'), findsOneWidget);
      },
    );

    testWidgets(
      'Skenario 2: Mencegah update jika admin tidak sengaja mengosongkan form',
      (WidgetTester tester) async {
        await loadEditPage(tester);

        // Cari kolom teks 'Nama Layanan' (indeks 0) dan hapus isinya
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(0), '');
        await tester.pump();

        // Scroll layar mencari tombol Ubah Layanan lalu tekan
        final btnSubmit = find.byType(CustomButton);
        await tester.ensureVisible(btnSubmit);
        await tester.tap(btnSubmit, warnIfMissed: false);
        await tester.pump();

        // Verifikasi: API update TIDAK boleh terpanggil karena dicegat oleh if(isEmpty)
        expect(fakeServiceProvider.isApiCalled, false);

        // 🔥 Bunuh Timer dari Get.snackbar('Error', 'Semua field harus diisi')
        await tester.pump(const Duration(seconds: 4));
      },
    );

    testWidgets(
      'Skenario 3: Simulasi sukses mengubah form dan menembak API Update',
      (WidgetTester tester) async {
        await loadEditPage(tester);

        // Admin mengubah form harga (indeks 2) menjadi 350000
        final textFields = find.byType(TextField);
        await tester.enterText(textFields.at(2), '350000');
        await tester.pump();

        // Klik tombol Ubah Layanan
        final btnSubmit = find.byType(CustomButton);
        await tester.ensureVisible(btnSubmit);
        await tester.tap(btnSubmit, warnIfMissed: false);
        await tester.pump();

        // Verifikasi Mutlak: API harus terpanggil!
        expect(fakeServiceProvider.isApiCalled, true);

        // Kita intip "koper" payload yang dikirim ke backend, apakah harganya sudah berubah?
        final payload = fakeServiceProvider.savedPayload!;
        expect(payload['basePrice'], 350000.0); // Harga baru
        expect(payload['name'], 'Servis AC Mobil'); // Nama tidak berubah

        // 🔥 Bunuh Timer dari Get.snackbar() (karena respons API kita set 400)
        await tester.pump(const Duration(seconds: 4));
      },
    );
  });
}
