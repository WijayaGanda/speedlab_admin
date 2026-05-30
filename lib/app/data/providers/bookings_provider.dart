import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/services/api_service.dart';
import 'package:intl/intl.dart';

class BookingsProvider extends ApiService {
  Future<Response> addBooking(Map<String, dynamic> data) async {
    return await post('api/bookings', data);
  }

  Future<Response> fetchAllBookings() async {
    return await get('api/bookings');
  }

  Future<Response> fetchMyBookings() async {
    return await get('api/bookings/my-bookings');
  }

  Future<Response> cancelBooking(String id) async {
    return await patch('api/bookings/$id/cancel', {});
  }

  Future<Response> updateStatusBooking(String id, String status) async {
    return await patch('api/bookings/$id/status', {'status': status});
  }

  Future<Response> fetchBookingsByDate(DateTime date) async {
    final formattedDate = DateFormat('yyyy-MM-dd').format(date);
    return await get('api/bookings/by-date', query: {'date': formattedDate});
  }
}
