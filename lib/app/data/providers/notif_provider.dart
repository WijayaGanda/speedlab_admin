import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';

class NotifProvider extends ApiService {
  Future<Response> registerFcmToken(Map<String, dynamic> data) async {
    return post('api/notifications/register-device', data);
  }
}
