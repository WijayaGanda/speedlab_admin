import 'dart:io';

import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';

class ServiceHistoryProvider extends ApiService {
  //APi untuk membuat riwayat servis baru
  Future<Response> createServiceHistory(Map<String, dynamic> data) async {
    return post('api/service-histories', data);
  }

  //Get Api untuk mendapatkan riwayat servis berdasarkan bookingId
  Future<Response> getServiceHistory(String bookingId) async {
    return get('api/service-histories/booking/$bookingId');
  }

  Future<Response> updateServiceHistory(
    String serviceHistoryId,
    Map<String, dynamic> data,
  ) async {
    return put('api/service-histories/$serviceHistoryId', data);
  }

  Future<Response> confirmServiceHistory(
    String serviceHistoryId,
    Map<String, dynamic> data,
  ) async {
    return put('api/service-histories/$serviceHistoryId', data);
  }

  Future<Response> uploadServiceHistoryImage(
    String serviceHistoryId,
    String filePath,
    String description,
  ) async {
    final formData = FormData({
      'photos': MultipartFile(File(filePath), filename: 'service_history.jpg'),
      'description': description,
    });

    return post(
      'api/service-histories/$serviceHistoryId/upload-photos',
      formData,
    );
  }
}
