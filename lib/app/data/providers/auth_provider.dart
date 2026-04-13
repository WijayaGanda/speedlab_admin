import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';

class AuthProvider extends ApiService {
  Future<Response> login(String email, String password) {
    return post('api/auth/login', {'email': email, 'password': password});
  }
}
