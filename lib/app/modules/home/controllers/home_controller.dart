import 'package:get/get.dart';
import 'package:speedlab_admin/app/data/models/bookings_model.dart';
import 'package:speedlab_admin/app/data/providers/bookings_provider.dart';
import 'package:speedlab_admin/app/data/services/auth_service.dart';

class HomeController extends GetxController {
  final authService = Get.find<AuthService>();
  final BookingsProvider provider;

  HomeController({required this.provider});

  var isLoading = false.obs;
  var bookings = <BookingsModel>[].obs;

  int get totalBookings => bookings.length;

  int get menungguVerifikasi =>
      bookings
          .where((b) => b.status?.toLowerCase() == "menunggu verifikasi")
          .length;

  int get bookingsVerifikasi =>
      bookings.where((b) => b.status?.toLowerCase() == "terverifikasi").length;

  int get bookingsDikerjakan =>
      bookings
          .where((b) => b.status?.toLowerCase() == "sedang dikerjakan")
          .length;

  int get bookingsSelesai =>
      bookings.where((b) => b.status?.toLowerCase() == 'selesai').length;

  int get bookingsDibatalkan =>
      bookings.where((b) => b.status?.toLowerCase() == 'dibatalkan').length;

  @override
  void onInit() {
    super.onInit();
    fetchAllBookings();
  }

  Future<void> fetchAllBookings() async {
    try {
      isLoading.value = true;
      final response = await provider.fetchAllBookings();
      if (response.statusCode == 200) {
        final bookingsResponse = BookingsResponse.fromJson(response.body);
        // bookings.value = bookingsResponse.data ?? [];
        bookings.assignAll(bookingsResponse.data ?? []);
      } else {
        Get.snackbar('Error', 'Failed to fetch bookings');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
