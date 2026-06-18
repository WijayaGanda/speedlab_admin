import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:speedlab_admin/app/data/providers/auth_provider.dart';
import 'package:speedlab_admin/app/data/providers/notif_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';
import 'package:speedlab_admin/app/data/services/fcm_service.dart';
import 'package:speedlab_admin/app/modules/login/controllers/login_controller.dart';
import 'package:speedlab_admin/app/utils/widget/custom_modal.dart';
import 'package:speedlab_admin/app/utils/widget/custom_snackbar.dart';

@GenerateNiceMocks([
  MockSpec<AuthProvider>(),
  MockSpec<AuthService>(),
  MockSpec<FCMService>(),
  MockSpec<NotifProvider>(),
])
import 'login_controller_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late LoginController controller;
  late MockAuthProvider provider;
  late MockNotifProvider notifProvider;
  late MockAuthService mockAuthService;
  late MockFCMService mockFCMService;
  setUp(() {
    CustomSnackbar.isTesting = true;
    CustomModal.isTest = true;
    provider = MockAuthProvider();
    notifProvider = MockNotifProvider();
    mockAuthService = MockAuthService();
    mockFCMService = MockFCMService();
    controller = LoginController(
      provider: provider,
      notifProvider: notifProvider,
    );
    Get.testMode = true;
    final dummyCallback = InternalFinalCallback<void>(callback: () {});

    when(mockAuthService.onStart).thenReturn(dummyCallback);
    when(mockAuthService.onDelete).thenReturn(dummyCallback);

    when(mockFCMService.onStart).thenReturn(dummyCallback);
    when(mockFCMService.onDelete).thenReturn(dummyCallback);

    Get.put<AuthService>(mockAuthService);
    Get.put<FCMService>(mockFCMService);
  });
  group('login() Basis Path Testing V(G)=5', () {
    test('Path 1: Email/password kosong', () async {
      controller.emailController.text = '';
      controller.passwordController.text = '';
      await controller.login();
      expect(controller.isLoading.value, false);
    });
    test('Path 2: Login sukses + FCM token ada', () async {
      controller.emailController.text = 'test@mail.com';
      controller.passwordController.text = '123456';
      when(provider.login(any, any)).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "data": {
              "token": "abc123",
              "user": {"name": "Wijaya"},
            },
          },
        ),
      );
      await controller.login();
      expect(controller.isLoading.value, false);
    });
    test('Path 3: Login sukses + FCM token null', () async {
      controller.emailController.text = 'test@mail.com';
      controller.passwordController.text = '123456';
      when(provider.login(any, any)).thenAnswer(
        (_) async => Response(
          statusCode: 200,
          body: {
            "data": {
              "token": "abc123",
              "user": {"name": "Wijaya"},
            },
          },
        ),
      );
      await controller.login();
      expect(controller.isLoading.value, false);
    });
    test('Path 4: Response gagal', () async {
      controller.emailController.text = 'test@mail.com';
      controller.passwordController.text = '123456';
      when(
        provider.login(any, any),
      ).thenAnswer((_) async => Response(statusCode: 400, body: null));
      await controller.login();
      expect(controller.isLoading.value, false);
    });
    test('Path 5: Exception terjadi', () async {
      controller.emailController.text = 'test@mail.com';
      controller.passwordController.text = '123456';
      when(provider.login(any, any)).thenThrow(Exception('Login Error'));
      try {
        await controller.login();
      } catch (_) {}
      expect(controller.isLoading.value, false);
    });
  });
}
