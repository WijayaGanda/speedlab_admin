import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:integration_test/integration_test.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/modules/login/views/login_view.dart';
import 'package:speedlab_admin/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Integration Testing V(G)=5', () {
    setUp(() {
      Get.testMode = true;

      if (!Get.isRegistered<AuthProvider>()) {
        Get.put<AuthProvider>(MockAuthProvider());
      }

      if (!Get.isRegistered<AuthService>()) {
        Get.put<AuthService>(AuthService());
      }

      if (!Get.isRegistered<NotifProvider>()) {
        Get.put<NotifProvider>(NotifProvider());
      }

      Get.put(
        LoginController(
          provider: Get.find<AuthProvider>(),
          notifProvider: Get.find<NotifProvider>(),
        ),
      );
    });

    // JANGAN Get.reset() di integration test
    tearDown(() async {
      Get.delete<LoginController>(force: true);

      await Future.delayed(const Duration(milliseconds: 300));
    });

    Future<void> buildLoginPage(WidgetTester tester) async {
      await tester.pumpWidget(
        GetMaterialApp(
          home: const LoginView(),
          getPages: [
            GetPage(
              name: '/dashboard',
              page:
                  () => const Scaffold(body: Center(child: Text('Dashboard'))),
            ),
          ],
        ),
      );

      await tester.pumpAndSettle();
    }

    // =========================
    // PATH 1
    // Email dan password kosong
    // =========================
    testWidgets('Path 1: Email dan password kosong', (tester) async {
      await buildLoginPage(tester);

      await tester.tap(find.text('Masuk'));

      await tester.pumpAndSettle();

      expect(find.text('Masuk'), findsOneWidget);
    });

    // =========================
    // PATH 2
    // Login sukses
    // =========================
    testWidgets('Path 2: Login sukses', (tester) async {
      await buildLoginPage(tester);

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'admin@gmail.com');

      await tester.enterText(fields.at(1), '123456');

      await tester.tap(find.text('Masuk'));

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Dashboard'), findsOneWidget);
    });

    // =========================
    // PATH 3
    // Password kosong
    // =========================
    testWidgets('Path 3: Password kosong', (tester) async {
      await buildLoginPage(tester);

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'admin@gmail.com');

      await tester.tap(find.text('Masuk'));

      await tester.pumpAndSettle();

      expect(find.text('Masuk'), findsOneWidget);
    });

    // =========================
    // PATH 4
    // Response gagal
    // =========================
    testWidgets('Path 4: Response gagal', (tester) async {
      Get.delete<AuthProvider>();

      Get.put<AuthProvider>(MockFailedAuthProvider());

      Get.delete<LoginController>();

      Get.put(
        LoginController(
          provider: Get.find<AuthProvider>(),
          notifProvider: Get.find<NotifProvider>(),
        ),
      );

      await buildLoginPage(tester);

      final fields = find.byType(TextField);

      await tester.enterText(fields.at(0), 'salah@gmail.com');

      await tester.enterText(fields.at(1), 'salah');

      await tester.tap(find.text('Masuk'));

      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Tetap di halaman login
      expect(find.text('Masuk'), findsOneWidget);
    });

    // =========================
    // PATH 5
    // Toggle password visibility
    // =========================
    testWidgets('Path 5: Toggle password visibility', (tester) async {
      await buildLoginPage(tester);

      final visibilityButton = find.byType(IconButton).last;

      await tester.tap(visibilityButton);

      await tester.pumpAndSettle();

      expect(find.byType(IconButton), findsWidgets);
    });
  });
}

// =========================
// MOCK SUCCESS
// =========================
class MockAuthProvider extends AuthProvider {
  @override
  Future<Response> login(String email, String password) async {
    // simulasi validasi login gagal
    if (email.isEmpty || password.isEmpty) {
      return Response(
        statusCode: 400,
        body: {'success': false, 'message': 'Email atau password kosong'},
      );
    }

    // simulasi login gagal
    if (email == 'salah@gmail.com') {
      return Response(
        statusCode: 401,
        body: {'success': false, 'message': 'Login gagal'},
      );
    }

    // login sukses
    return Response(
      statusCode: 200,
      body: {
        'success': true,
        'data': {
          'token': 'fake_token_123',
          'user': {'name': 'Admin'},
        },
      },
    );
  }
}

// =========================
// MOCK FAILED
// =========================
class MockFailedAuthProvider extends AuthProvider {
  @override
  Future<Response> login(String email, String password) async {
    return Response(
      statusCode: 400,
      body: {'success': false, 'message': 'Login gagal'},
    );
  }
}
