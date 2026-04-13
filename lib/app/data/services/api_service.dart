import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ApiService extends GetConnect {
  @override
  void onInit() {
    super.onInit();
    httpClient.baseUrl = 'https://backend-speedlab.vercel.app/';
    httpClient.timeout = const Duration(seconds: 30);
    httpClient.addRequestModifier<void>((request) async {
      final token = GetStorage().read('token');
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });

    httpClient.addResponseModifier<void>((request, response) async {
      if (response.statusCode == 401) {
        // Handle unauthorized access, e.g., by redirecting to login
        Get.offAllNamed('/login');
      }
      return response;
    });
  }
}
