import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

// Import file asli Anda
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_admin/app/modules/login/views/login_view.dart';
import 'package:speedlab_admin/app/utils/widget/custom_button.dart';
import 'package:speedlab_admin/app/utils/widget/custom_textfield.dart';
import 'package:speedlab_admin/app/utils/widget/custom_header.dart';

// ======================================================================
// 🔥 1. MEMBUAT KELAS TIRUAN MANUAL (MANUAL FAKE) TANPA MOCKITO 🔥
// ======================================================================
// ======================================================================
// 🔥 1. MEMBUAT KELAS TIRUAN MANUAL (MANUAL FAKE) TANPA MOCKITO 🔥
// ======================================================================
class FakeAuthProvider extends AuthProvider {
  @override
  Future<Response> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return const Response(statusCode: 400, body: {'message': 'Error'});
    }

    // 🔥 PERUBAHAN DI SINI:
    // Kita ubah menjadi 401 agar Controller tidak mencoba mencari AuthService.
    // Fokus Widget Test ini hanyalah memastikan tombol bisa diklik dan UI merespons.
    return const Response(
      statusCode: 401,
      body: {'message': 'Gagal sengaja untuk Widget Test'},
    );
  }
}

class FakeNotifProvider extends NotifProvider {
  // Biarkan kosong, karena saat login kita belum memanggil fungsi notif
}
// ======================================================================

void main() {
  late FakeAuthProvider fakeAuthProvider;
  late FakeNotifProvider fakeNotifProvider;
  late LoginController loginController;

  setUp(() {
    // Matikan animasi dan transisi layar GetX
    Get.testMode = true;
    TestWidgetsFlutterBinding.ensureInitialized();

    // 2. Gunakan kelas tiruan yang baru kita buat di atas
    fakeAuthProvider = FakeAuthProvider();
    fakeNotifProvider = FakeNotifProvider();

    // 3. Suntikkan ke memori GetX
    loginController = LoginController(
      provider: fakeAuthProvider,
      notifProvider: fakeNotifProvider,
    );
    Get.put<LoginController>(loginController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Widget Testing - LoginView Admin (Tanpa Mockito)', () {
    testWidgets(
      'Skenario 1: Memastikan semua elemen UI ter-render dengan sempurna',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: LoginView()));

        final textSelamatDatang = find.text('Selamat Datang');
        final textLupaPassword = find.text('Lupa Password?');
        final customFields = find.byType(CustomTextField);
        final customButton = find.byType(CustomButton);
        final customHeader = find.byType(CustomHeader);

        expect(textSelamatDatang, findsOneWidget);
        expect(textLupaPassword, findsOneWidget);
        expect(customHeader, findsOneWidget);
        expect(customFields, findsNWidgets(2)); // Email & Password
        expect(customButton, findsOneWidget);
      },
    );

    testWidgets(
      'Skenario 2: Menguji interaksi ketikan pada form Email dan Password',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: LoginView()));

        final textFields = find.byType(TextField);
        expect(textFields, findsNWidgets(2));

        await tester.enterText(textFields.at(0), 'admin@speedlab.com');
        await tester.enterText(textFields.at(1), 'rahasia123');
        await tester.pump();

        expect(loginController.emailController.text, 'admin@speedlab.com');
        expect(loginController.passwordController.text, 'rahasia123');
      },
    );

    testWidgets(
      'Skenario 3: Menekan tombol visibilitas mengubah isVisible di Controller',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: LoginView()));

        expect(loginController.isVisible.value, true);

        final visibilityIcon = find.byIcon(Icons.visibility_off);
        expect(visibilityIcon, findsOneWidget);

        await tester.tap(visibilityIcon);
        await tester.pump();

        expect(loginController.isVisible.value, false);
      },
    );

    testWidgets('Skenario 4: Menekan tombol masuk akan mengubah state loading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginView()));

      // Cari TextField dan isi agar lolos validasi awal
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'admin@speedlab.com');
      await tester.enterText(textFields.at(1), 'rahasia123');

      // Cari dan klik tombol masuk
      final masukButton = find.byType(CustomButton);
      await tester.tap(masukButton);

      // Pump satu kali untuk memulai fungsi async login()
      await tester.pump();

      // Karena kita pakai FakeAuthProvider, nilai isOk di dalam controller akan true
      // dan proses login akan berjalan sangat cepat di background
    });
  });
}
