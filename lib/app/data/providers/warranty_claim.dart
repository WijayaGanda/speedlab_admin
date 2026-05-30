import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';

class WarrantyClaimProvider extends ApiService {
  Future<Response> submitWarrantyClaim(Map<String, dynamic> claimData) async {
    return await post('api/warranties', claimData);
  }

  Future<Response> getMyWarrantyClaims() async {
    return await get('api/warranties/my-claims');
  }

  Future<Response> fetchMyWarrantyClaims(String? bookingId) async {
    return await get('api/warranties/my-claims/$bookingId');
  }

  Future<Response> fetchallWarrantyClaims() async {
    return await get('api/warranties');
  }

  Future<Response> verifyWarranties(String? warrantyId, String status) async {
    return await patch('api/warranties/$warrantyId/verify', {'status': status});
  }

  Future<Response> rejectWarranty(
    String? warrantyId,
    String status, {
    required String rejectionReason,
  }) async {
    return await patch('api/warranties/$warrantyId/verify', {
      'status': status,
      'rejectionReason': rejectionReason,
    });
  }
}
