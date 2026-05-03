import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';

class ServiceProvider extends ApiService {
  Future<Response> fetchServices() async {
    return await get('api/services');
  }

  Future<Response> createServices(Map<String, dynamic> data) async {
    return await post('api/services', data);
  }

  Future<Response> updateServices(String id, Map<String, dynamic> data) async {
    return await put('api/services/$id', data);
  }

  Future<Response> deleteService(String id) async {
    return await delete('api/services/$id');
  }
}
